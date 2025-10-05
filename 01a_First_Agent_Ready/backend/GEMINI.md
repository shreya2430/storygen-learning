  ### **Coding Guidelines**
  **1. Python Best Practices:**

  *   **Type Hinting:** All function and method signatures should include type hints for arguments and return values.
  *   **Docstrings:** Every module, class, and function should have a docstring explaining its purpose, arguments, and return value, following a consistent format like reStructuredText or 
  Google Style.
  *   **Linter & Formatter:** Use a linter like `ruff` or `pylint` and a code formatter like `black` to enforce a consistent style and catch potential errors.
  *   **Imports:** Organize imports into three groups: standard library, third-party libraries, and local application imports. Sort them alphabetically within each group.
  *   **Naming Conventions:**
      *   `snake_case` for variables, functions, and methods.
      *   `PascalCase` for classes.
      *   `UPPER_SNAKE_CASE` for constants.
  *   **Dependency Management:** All Python dependencies must be listed in a `requirements.txt` file.

  **2. Web APIs (FastAPI):**

  *   **Data Validation:** Use `pydantic` models for request and response data validation.
  *   **Dependency Injection:** Utilize FastAPI's dependency injection system for managing resources like database connections.
  *   **Error Handling:** Implement centralized error handling using middleware or exception handlers.
  *   **Asynchronous Code:** Use `async` and `await` for I/O-bound operations to improve performance.
