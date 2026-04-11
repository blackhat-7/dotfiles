class ToolError(Exception):
    """Base error for AI tools."""


class ValidationError(ToolError):
    """Raised when tool input is invalid."""


class ApiError(ToolError):
    """Raised when an external API request fails."""
