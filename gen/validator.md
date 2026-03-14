# Validation Schema Generator

Generate validation schemas from existing type definitions, interfaces, or model classes.

## Arguments

$ARGUMENTS - `<type-name>` or `<file-path>` - Either the name of a type/interface to search for in the project, or a direct path to a file containing type definitions.

## Instructions

### Step 1: Locate Type Definitions

1. If the argument is a file path (contains `/` or `.`), read that file directly.
2. If the argument is a type name, search the project for matching definitions:
   - TypeScript: search for `interface <TypeName>`, `type <TypeName>`, `class <TypeName>`
   - Python: search for `class <TypeName>(BaseModel)`, `class <TypeName>(TypedDict)`, `@dataclass class <TypeName>`, `class <TypeName>:`
   - Go: search for `type <TypeName> struct`
   - Java: search for `class <TypeName>`, `record <TypeName>`
3. If multiple matches are found, list them and process all of them (or ask the user to disambiguate if there are more than 5).
4. If no match is found, report the error and stop.

### Step 2: Parse Type Structure

Extract from each type definition:
- **Field name**
- **Field type** (string, number, boolean, array, nested object, enum, union, optional)
- **Whether required or optional**
- **Any existing constraints** (JSDoc comments, Python field metadata, decorators)
- **Nested types** (recursively parse referenced types)
- **Default values** if any

Build an internal representation of the type structure:
```
fields: [
  { name, type, required, constraints, nestedType, defaultValue }
]
```

### Step 3: Detect Project Stack and Validation Library

Check what validation libraries are already in use:

**TypeScript**:
- `zod` in package.json --> Generate Zod schemas (preferred)
- `yup` in package.json --> Generate Yup schemas
- `joi` in package.json --> Generate Joi schemas
- `class-validator` in package.json --> Generate class-validator decorators
- None found --> Default to Zod, note that it needs to be installed

**Python**:
- `pydantic` in requirements --> Generate Pydantic models (if source is not already Pydantic)
- `marshmallow` in requirements --> Generate Marshmallow schemas
- `cerberus` in requirements --> Generate Cerberus schemas
- `attrs` + `cattrs` --> Generate attrs validators
- None found --> Default to Pydantic, note that it needs to be installed

### Step 4: Generate Validation Schemas

#### TypeScript / Zod

For each type, generate a Zod schema:

```
Field type mapping:
- string       --> z.string()
- number       --> z.number()
- boolean      --> z.boolean()
- Date         --> z.date() or z.string().datetime()
- array of T   --> z.array(<T schema>)
- enum         --> z.enum([...values])
- union        --> z.union([...schemas])
- nested obj   --> Reference to that object's schema
- null | T     --> z.nullable(<T schema>)
- optional     --> .optional()
- Record<K,V>  --> z.record(keySchema, valueSchema)

Smart constraints (infer from field name):
- *email*      --> .email("Invalid email address")
- *url*, *link*, *href*  --> .url("Invalid URL")
- *phone*      --> .regex(/^\+?[1-9]\d{1,14}$/, "Invalid phone number")
- *password*   --> .min(8, "Password must be at least 8 characters")
- *name*       --> .min(1, "Name is required").max(255)
- *age*        --> .int().min(0).max(150)
- *id*, *Id*   --> .uuid() or .string().min(1)
- *count*, *quantity* --> .int().nonnegative()
- *price*, *amount*   --> .number().nonnegative()
- *zip*, *postal*     --> .regex(/^\d{5}(-\d{4})?$/, "Invalid zip code")
- *slug*       --> .regex(/^[a-z0-9]+(?:-[a-z0-9]+)*$/, "Invalid slug")

If a field already has JSDoc constraints like @min, @max, @pattern, use those instead.
```

Generate:
1. The Zod schema object (`export const <TypeName>Schema = z.object({...})`)
2. Inferred TypeScript type from the schema (`export type <TypeName>Validated = z.infer<typeof <TypeName>Schema>`)
3. Partial schema for updates (`export const <TypeName>UpdateSchema = <TypeName>Schema.partial()`)
4. A validate helper function:
```typescript
export function validate<TypeName>(data: unknown): { success: true; data: TypeName } | { success: false; errors: z.ZodError } {
  const result = <TypeName>Schema.safeParse(data);
  if (result.success) return { success: true, data: result.data };
  return { success: false, errors: result.error };
}
```

#### TypeScript / Yup

Similar approach but using Yup syntax:
- `yup.string()`, `yup.number()`, `yup.boolean()`, `yup.array()`, `yup.object()`
- `.required()` for required fields
- Same smart constraint inference

#### Python / Pydantic

Generate a Pydantic model (if source was not already Pydantic):

```
Field type mapping:
- str           --> str with Field(min_length=..., max_length=..., pattern=...)
- int           --> int with Field(ge=..., le=...)
- float         --> float with Field(ge=..., le=...)
- bool          --> bool
- datetime      --> datetime
- list[T]       --> list[T]
- Optional[T]   --> Optional[T] = None
- enum          --> Literal[...] or Enum class

Smart constraints:
- *email*       --> EmailStr (from pydantic)
- *url*         --> HttpUrl (from pydantic)
- *name*        --> Field(min_length=1, max_length=255)
- *password*    --> Field(min_length=8)
- *age*         --> Field(ge=0, le=150)
- *price*       --> Field(ge=0, decimal_places=2)

Add @field_validator for complex validations.
```

Generate:
1. The Pydantic model class
2. A CreateModel variant (required fields only)
3. An UpdateModel variant (all fields Optional)
4. A validate helper:
```python
def validate_<model_name>(data: dict) -> tuple[bool, <ModelName> | list[str]]:
    try:
        return True, <ModelName>.model_validate(data)
    except ValidationError as e:
        return False, [err["msg"] for err in e.errors()]
```

#### Python / Marshmallow

Generate a Marshmallow Schema class:
- `fields.String()`, `fields.Integer()`, `fields.Boolean()`, etc.
- `required=True` for required fields
- `validate=[...]` for constraints
- `@validates` decorators for complex validation
- `@validates_schema` for cross-field validation

### Step 5: Handle Nested Types

For each nested/referenced type:
1. Generate its validation schema first (dependency order)
2. Reference it in the parent schema
3. Ensure no circular references (use `z.lazy()` in Zod or `ForwardRef` in Python if needed)

### Step 6: Generate Test Cases (Optional but Recommended)

Generate a companion test file with:
- Valid data that should pass validation
- Invalid data for each field (wrong type, missing required, constraint violation)
- Edge cases (empty strings, negative numbers, null values, extra fields)
- Nested object validation tests

### Step 7: File Placement

Place the generated schema file adjacent to the type definition:
- If types are in `types/user.ts`, put schema in `validators/user.validator.ts` or `schemas/user.schema.ts`
- If types are in `models/user.py`, put schema in `schemas/user_schema.py` or `validators/user_validator.py`
- Match the project's existing pattern for schema file locations

### Step 8: Summary

Print:
1. Source type(s) processed with field count
2. Generated schema file path(s)
3. Validation library used
4. Smart constraints applied (list each field and the constraint inferred)
5. Any fields where constraints could not be inferred (suggest the user review)
6. Dependencies that may need installing
