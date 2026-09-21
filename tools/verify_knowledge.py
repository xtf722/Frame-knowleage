#!/usr/bin/env python3
"""离线检查知识库链接、证据结构及可选源码漂移；不会修改快照。"""

import argparse
import hashlib
import html
import json
import re
from pathlib import Path
from urllib.parse import unquote, urlsplit


def without_fences(text):
    lines, fence = [], None
    for line in text.splitlines():
        marker = re.match(r"^ {0,3}(`{3,}|~{3,})(.*)$", line)
        if marker:
            token, tail = marker.groups()
            if fence is None:
                fence = token
                continue
            if token[0] == fence[0] and len(token) >= len(fence) and not tail.strip():
                fence = None
                continue
        if fence is None:
            lines.append(line)
    return re.sub(r"<!--.*?-->", "", "\n".join(lines), flags=re.S)


def anchors(text):
    found = set(re.findall(r'<a\b[^>]*\bid=["\']([^"\']+)["\']', text, re.I))
    headings, lines = [], text.splitlines()
    for index, line in enumerate(lines):
        match = re.match(r"^ {0,3}#{1,6}\s+(.+?)\s*#*\s*$", line)
        if match:
            headings.append(match.group(1))
        elif index and re.fullmatch(r" {0,3}(?:=+|-+)\s*", line) and lines[index - 1].strip():
            headings.append(lines[index - 1].strip())
    # 常见 GitHub slug：保留中文/字母数字，移除标点，重复标题追加序号。
    used = set()
    for heading in headings:
        heading = re.sub(r"!?\[([^]]+)\]\([^)]*\)", r"\1", heading)
        heading = re.sub(r"(?<!\w)_{1,2}(.+?)_{1,2}(?!\w)", r"\1", heading)
        heading = html.unescape(re.sub(r"<[^>]+>", "", heading)).lower()
        base = re.sub(r"[^\w\- ]", "", heading).replace(" ", "-")
        slug, number = base, 0
        while slug in used:
            number += 1
            slug = f"{base}-{number}"
        used.add(slug)
        found.add(slug)
    return found


def link_targets(text):
    # 去掉行内代码，避免把命令示例中的括号误当链接；保留真实链接目标。
    text = re.sub(r"(`+)(?!`)(.+?)\1(?!`)", "", text)
    pattern = r"!?\[[^]\n]*\]\(\s*(<[^>\n]+>|(?:[^\s()]|\([^()]*\))+)(?:\s+[^)]+)?\s*\)"
    targets = re.findall(pattern, text)
    targets += re.findall(r"^ {0,3}\[[^]\n]+\]:\s*(<[^>\n]+>|\S+)", text, re.M)
    return [html.unescape(target.strip("<>")) for target in targets]


def inside(path, root):
    try:
        path.relative_to(root)
        return True
    except ValueError:
        return False


def safe_source_path(value):
    if not isinstance(value, str) or not value or re.search(r'[\\:\x00<>"|?*]', value):
        return False
    parts = value.split("/")
    if parts[:3] == ["..", "..", "packages"]:
        parts = parts[3:]
    return bool(parts) and all(part not in ("", ".", "..") for part in parts)


def check(root, source_root=None, manifest="evidence/sources.json"):
    errors, drift, external = [], [], 0
    manifest_path = (root / manifest).resolve()
    if not inside(manifest_path, root):
        print("来源清单必须位于知识库目录内。")
        return 1
    for name in ("README.md", "AGENTS.md", "learning-map.md", "lifecycle-map.md"):
        if not (root / name).is_file():
            errors.append(f"缺少入口文档: {name}")
    for name in ("modules", "foundations"):
        if not (root / name).is_dir():
            errors.append(f"缺少目录: {name}")
    docs = {}
    for path in root.rglob("*.md"):
        if any(part.startswith(".") for part in path.relative_to(root).parts[:-1]):
            continue
        try:
            resolved = path.resolve()
            if not inside(resolved, root):
                errors.append(f"文档链接越界: {path.relative_to(root)}")
                continue
            docs[resolved] = without_fences(path.read_text(encoding="utf-8-sig"))
        except (OSError, UnicodeError) as error:
            errors.append(f"文档不可读: {path.relative_to(root)}: {error}")
    all_anchors = {path: anchors(text) for path, text in docs.items()}
    for path, text in docs.items():
        for target in link_targets(text):
            try:
                url = urlsplit(target)
                destination = (path.parent / unquote(url.path)).resolve() if url.path else path
            except (OSError, ValueError, RuntimeError):
                errors.append(f"链接格式无效: {path.relative_to(root)} -> {target}")
                continue
            if url.scheme or url.netloc:
                external += 1
                continue
            label = f"{path.relative_to(root)} -> {target}"
            if not inside(destination, root) or not destination.is_file():
                errors.append(f"断链或越界: {label}")
            elif url.fragment and destination in docs and unquote(url.fragment) not in all_anchors[destination]:
                errors.append(f"锚点不存在: {label}")
    try:
        evidence = json.loads(manifest_path.read_text(encoding="utf-8-sig"))
    except (OSError, UnicodeError, ValueError) as error:
        evidence = {}
        errors.append(f"证据不可读: {error}")
    if not isinstance(evidence, dict):
        evidence = {}
    if type(evidence.get("schema_version")) is not int or evidence.get("schema_version") != 1:
        errors.append("evidence.schema_version 必须为 1")
    repositories = evidence.get("repositories", {})
    # 旧快照继续以 frame_app 为根；App 快照须显式声明，不能借用 Frame 仓库身份。
    primary_repository = evidence.get("primary_repository", "frame_app")
    if primary_repository not in ("frame_app", "app"):
        errors.append("primary_repository 必须为 frame_app 或 app")
        primary_repository = "frame_app"
    for name in (primary_repository, "workspace"):
        repo = repositories.get(name, {}) if isinstance(repositories, dict) else {}
        if not isinstance(repo, dict) or not re.fullmatch(r"[0-9a-fA-F]{40}|[0-9a-fA-F]{64}", str(repo.get("head", ""))) or type(repo.get("working_tree_dirty")) is not bool:
            errors.append(f"repositories.{name} 的 head/working_tree_dirty 无效")
    sources = evidence.get("sources")
    if not isinstance(sources, list) or not sources:
        errors.append("sources 必须是非空数组")
        sources = []
    ids, paths = set(), set()
    for index, item in enumerate(sources):
        if not isinstance(item, dict):
            errors.append(f"sources[{index}] 必须为对象")
            continue
        sid, source, digest = item.get("id"), item.get("path"), item.get("sha256")
        if not isinstance(sid, str) or not re.fullmatch(r"source-[0-9a-f]{10}", sid) or sid in ids:
            errors.append(f"source id 无效或重复: {sid}")
        ids.add(str(sid))
        valid_path = safe_source_path(source)
        if not valid_path or source in paths:
            errors.append(f"source path 无效或重复: {source}")
        paths.add(str(source))
        if not isinstance(digest, str) or not re.fullmatch(r"[0-9a-fA-F]{64}", digest):
            errors.append(f"sha256 无效: {sid}")
        used_by = item.get("used_by")
        if not isinstance(used_by, list) or not used_by:
            errors.append(f"used_by 必须包含至少一篇文档: {sid}")
        else:
            for doc in used_by:
                target = (root / doc).resolve() if safe_source_path(doc) and not doc.startswith("../") else None
                if target not in docs or not inside(target, root):
                    errors.append(f"used_by 文档不存在或越界: {sid}: {doc}")
        fragments = item.get("source_fragments")
        if not isinstance(fragments, list) or any(not isinstance(value, str) for value in fragments):
            errors.append(f"source_fragments 必须为字符串数组: {sid}")
        if source_root is not None and valid_path:
            source_file = (source_root / source).resolve()
            allowed = (source_root / "../../packages").resolve() if source.startswith("../../packages/") else source_root
            if not inside(source_file, allowed) or not source_file.is_file():
                errors.append(f"源码缺失或越界: {source}")
                continue
            try:
                actual = hashlib.sha256(source_file.read_bytes()).hexdigest()
                if isinstance(digest, str) and actual != digest.lower():
                    drift.append(f"DRIFT {source}: expected={digest} actual={actual}")
            except OSError as error:
                errors.append(f"源码不可读: {source}: {error}")
    for message in errors + drift:
        print(message)
    print(f"离线检查: {len(docs)} 篇 Markdown；跳过 {external} 个外部链接，不进行在线可达性检查。")
    print(f"结构/断链错误={len(errors)}；源码 DRIFT={len(drift)}；未自动刷新任何证据。")
    # 结构问题优先返回 1；完整结构中的源码漂移返回 2，便于 CI 区分处理。
    return 1 if errors else 2 if drift else 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path, help="所选清单主仓库的本地源码根；可选 hash 对照")
    parser.add_argument("--manifest", default="evidence/sources.json", help="知识库内的来源清单；默认保留原专题快照")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    return check(root, args.source_root.resolve() if args.source_root else None, args.manifest)


if __name__ == "__main__":
    raise SystemExit(main())
