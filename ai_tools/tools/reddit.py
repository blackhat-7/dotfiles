from __future__ import annotations

import json
import urllib.error
import urllib.parse
import urllib.request
from typing import Any

from ai_tools.core.errors import ApiError, ValidationError
from ai_tools.core.registry import ToolSpec, registry

BASE_URL = "https://www.reddit.com"
USER_AGENT = "ai-tools/0.1 (reddit-json-client)"
VALID_SEARCH_SORTS = {"relevance", "hot", "top", "new", "comments"}
VALID_POST_SORTS = {"hot", "new", "top", "rising", "controversial"}
VALID_TIME = {"hour", "day", "week", "month", "year", "all"}
VALID_OPS = {"search", "posts", "subreddit", "post", "user"}


def _api_get(path: str, params: dict[str, Any] | None = None) -> Any:
    query = {"raw_json": "1"}
    if params is not None:
        query.update({key: value for key, value in params.items() if value is not None})
    url = f"{BASE_URL}/{path}.json?{urllib.parse.urlencode(query)}"
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            return json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        if exc.code == 404:
            raise ApiError(f"not found: {path}") from exc
        if exc.code == 429:
            raise ApiError("rate limited by Reddit") from exc
        raise ApiError(f"reddit http error: {exc.code}") from exc
    except urllib.error.URLError as exc:
        raise ApiError(f"reddit request failed: {exc.reason}") from exc


def _require_string(args: dict[str, Any], key: str) -> str:
    value = args.get(key)
    if not isinstance(value, str) or value == "":
        raise ValidationError(f"missing or invalid {key}")
    return value


def _optional_string(args: dict[str, Any], key: str) -> str | None:
    value = args.get(key)
    if value is None:
        return None
    if not isinstance(value, str) or value == "":
        raise ValidationError(f"invalid {key}")
    return value


def _optional_int(
    args: dict[str, Any], key: str, minimum: int, maximum: int
) -> int | None:
    value = args.get(key)
    if value is None:
        return None
    if isinstance(value, bool) or not isinstance(value, int):
        raise ValidationError(f"invalid {key}")
    if value < minimum or value > maximum:
        raise ValidationError(f"invalid {key}")
    return value


def _require_name(args: dict[str, Any], key: str, *, allow_dash: bool = False) -> str:
    value = _require_string(args, key)
    if len(value) > 32:
        raise ValidationError(f"invalid {key}")
    allowed_extra = {"_"}
    if allow_dash:
        allowed_extra.add("-")
    if not all(
        character.isalnum() or character in allowed_extra for character in value
    ):
        raise ValidationError(f"invalid {key}")
    return value


def _optional_name(args: dict[str, Any], key: str) -> str | None:
    value = args.get(key)
    if value is None:
        return None
    if not isinstance(value, str) or value == "":
        raise ValidationError(f"invalid {key}")
    if len(value) > 32:
        raise ValidationError(f"invalid {key}")
    if not all(character.isalnum() or character == "_" for character in value):
        raise ValidationError(f"invalid {key}")
    return value


def _require_enum(args: dict[str, Any], key: str, allowed: set[str]) -> str:
    value = _require_string(args, key)
    if value not in allowed:
        raise ValidationError(f"invalid {key}")
    return value


def _optional_enum(args: dict[str, Any], key: str, allowed: set[str]) -> str | None:
    value = _optional_string(args, key)
    if value is None:
        return None
    if value not in allowed:
        raise ValidationError(f"invalid {key}")
    return value


def _clean_post(raw: dict[str, Any]) -> dict[str, Any]:
    data = raw.get("data", raw)
    return {
        "id": data.get("id"),
        "title": data.get("title"),
        "subreddit": data.get("subreddit"),
        "author": data.get("author"),
        "score": data.get("score"),
        "upvote_ratio": data.get("upvote_ratio"),
        "comments": data.get("num_comments"),
        "permalink": f"https://reddit.com{data.get('permalink', '')}",
        "url": data.get("url"),
        "selftext": data.get("selftext") or "",
        "flair": data.get("link_flair_text"),
    }


def _clean_comment(raw: dict[str, Any]) -> dict[str, Any]:
    data = raw.get("data", raw)
    return {
        "id": data.get("id"),
        "author": data.get("author"),
        "body": data.get("body") or "",
        "score": data.get("score"),
    }


def _clean_subreddit(raw: dict[str, Any]) -> dict[str, Any]:
    data = raw.get("data", raw)
    return {
        "name": data.get("display_name"),
        "title": data.get("title"),
        "description": data.get("public_description") or "",
        "subscribers": data.get("subscribers"),
        "active_users": data.get("accounts_active"),
        "nsfw": data.get("over18"),
        "url": f"https://reddit.com/r/{data.get('display_name', '')}",
    }


def _clean_user(raw: dict[str, Any]) -> dict[str, Any]:
    data = raw.get("data", raw)
    return {
        "name": data.get("name"),
        "link_karma": data.get("link_karma"),
        "comment_karma": data.get("comment_karma"),
        "verified": data.get("verified"),
        "is_mod": data.get("is_mod"),
    }


def _reddit_search(args: dict[str, Any]) -> dict[str, Any]:
    query = _require_string(args, "query")
    subreddit = _optional_name(args, "subreddit")
    sort = _optional_enum(args, "sort", VALID_SEARCH_SORTS) or "relevance"
    time = _optional_enum(args, "time", VALID_TIME) or "all"
    limit = _optional_int(args, "limit", 1, 100) or 10

    if subreddit is not None:
        path = f"r/{subreddit}/search"
        params = {
            "q": query,
            "restrict_sr": "1",
            "sort": sort,
            "t": time,
            "limit": limit,
        }
    else:
        path = "search"
        params = {"q": query, "sort": sort, "t": time, "limit": limit}

    listing = _api_get(path, params).get("data", {})
    return {
        "items": [_clean_post(item) for item in listing.get("children", [])],
        "next_cursor": listing.get("after"),
    }


def _reddit_posts(args: dict[str, Any]) -> dict[str, Any]:
    subreddit = _require_name(args, "subreddit")
    sort = _optional_enum(args, "sort", VALID_POST_SORTS) or "hot"
    limit = _optional_int(args, "limit", 1, 100) or 10
    listing = _api_get(f"r/{subreddit}/{sort}", {"limit": limit}).get("data", {})
    return {
        "items": [_clean_post(item) for item in listing.get("children", [])],
        "next_cursor": listing.get("after"),
    }


def _reddit_subreddit(args: dict[str, Any]) -> dict[str, Any]:
    subreddit = _require_name(args, "subreddit")
    return _clean_subreddit(_api_get(f"r/{subreddit}/about"))


def _reddit_post(args: dict[str, Any]) -> dict[str, Any]:
    post_id = _require_string(args, "post_id")
    if not (5 <= len(post_id) <= 12 and post_id.isascii() and post_id.isalnum()):
        raise ValidationError("invalid post_id")
    comments_limit = _optional_int(args, "comments", 1, 100) or 20
    response = _api_get(f"comments/{post_id}", {"limit": comments_limit})
    if not isinstance(response, list) or len(response) < 2:
        raise ApiError("unexpected reddit post response")
    post_listing = response[0].get("data", {}).get("children", [])
    comment_listing = response[1].get("data", {}).get("children", [])
    if not post_listing:
        raise ApiError("post not found")
    return {
        "post": _clean_post(post_listing[0]),
        "comments": [
            _clean_comment(item) for item in comment_listing if item.get("kind") == "t1"
        ],
    }


def _reddit_user(args: dict[str, Any]) -> dict[str, Any]:
    username = _require_name(args, "username", allow_dash=True)
    posts_limit = _optional_int(args, "posts", 1, 100) or 10
    about = _clean_user(_api_get(f"user/{username}/about"))
    listing = _api_get(f"user/{username}/submitted", {"limit": posts_limit}).get(
        "data", {}
    )
    return {
        "user": about,
        "posts": [_clean_post(item) for item in listing.get("children", [])],
    }


def reddit(args: dict[str, Any]) -> dict[str, Any]:
    op = _require_enum(args, "op", VALID_OPS)
    if op == "search":
        return _reddit_search(args)
    if op == "posts":
        return _reddit_posts(args)
    if op == "subreddit":
        return _reddit_subreddit(args)
    if op == "post":
        return _reddit_post(args)
    return _reddit_user(args)


registry.register(
    ToolSpec(
        "reddit",
        "Read Reddit.",
        {
            "type": "object",
            "properties": {
                "op": {"type": "string", "enum": sorted(VALID_OPS)},
                "query": {"type": "string"},
                "subreddit": {"type": "string"},
                "sort": {
                    "type": "string",
                    "enum": sorted(VALID_SEARCH_SORTS | VALID_POST_SORTS),
                },
                "time": {"type": "string", "enum": sorted(VALID_TIME)},
                "limit": {"type": "integer", "minimum": 1, "maximum": 100},
                "post_id": {"type": "string"},
                "comments": {"type": "integer", "minimum": 1, "maximum": 100},
                "username": {"type": "string"},
                "posts": {"type": "integer", "minimum": 1, "maximum": 100},
            },
            "required": ["op"],
            "additionalProperties": False,
        },
        reddit,
    )
)
