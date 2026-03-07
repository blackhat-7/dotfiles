Review the code and check each of the following:

- Always think of a SHORT and SIMPLE solution. Avoid complexity where possible
- Keep things generic and extensible. We need a BALANCE between SHORT and SIMPLE vs GENERIC and EXTENSIBLE
- TYPE HINT always. Avoid using `any` type
- Never use blank `Exception`. Check what specific exceptions need to be CAUGHT and what need to be RERAISED. No meaningless raises if the code is already raising a specific exception
- Use PYDANTIC classes to validate data interacting with outside code. Use DATACLASSES in other cases, never default python classes
- Use classes only when it makes sense e.g. data models, too many args in a function, common logic/variables for multiple functions etc.
- AVOID OBVIOUS COMMENTS. Comments should only explain AMBIGUOUS or COMPLEX logic
