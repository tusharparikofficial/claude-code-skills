# Form Component Generator

Generate a fully validated, accessible form component from a schema, type, or model definition.

## Arguments

$ARGUMENTS - `<schema-or-type-name> [framework]` - Name of a type/schema/model to generate a form for. Optionally specify the frontend framework (react, vue, svelte). If omitted, the framework is auto-detected.

## Instructions

### Step 1: Parse Arguments

- **schema-or-type-name**: The first argument. This can be:
  - A type/interface name (e.g., `User`, `CreateUserInput`)
  - A file path to a schema or type definition
  - A Zod schema name (e.g., `UserSchema`)
  - A Pydantic model name
- **framework** (optional): The second argument. One of: `react`, `vue`, `svelte`, `angular`. If not provided, auto-detect.

### Step 2: Detect Frontend Framework

If framework not specified, search the project:
- `react`, `react-dom` in package.json --> **React**
- `next` in package.json --> **React** (Next.js)
- `vue` in package.json --> **Vue**
- `nuxt` in package.json --> **Vue** (Nuxt)
- `svelte` in package.json --> **Svelte**
- `@angular/core` in package.json --> **Angular**

Also detect form libraries already in use:
- `react-hook-form` --> Use React Hook Form
- `formik` --> Use Formik
- `vee-validate` --> Use VeeValidate
- `@formkit/vue` --> Use FormKit
- None --> Default to React Hook Form (React), VeeValidate (Vue), native (Svelte)

Detect UI component libraries:
- `@shadcn/ui` or `shadcn` components directory --> Use shadcn/ui components
- `@radix-ui` --> Use Radix primitives
- `@mui/material` --> Use MUI components
- `antd` --> Use Ant Design components
- `@headlessui` --> Use Headless UI
- `vuetify` --> Use Vuetify
- None --> Generate with plain HTML + CSS classes (Tailwind if `tailwindcss` is a dependency)

### Step 3: Locate and Parse the Schema/Type

1. Search the project for the named type, interface, Zod schema, or Pydantic model.
2. Extract all fields with:
   - Field name
   - Field type (determines the input type)
   - Required or optional
   - Validation constraints (min, max, pattern, enum values)
   - Default values
   - Description/label (from JSDoc, docstrings, or field metadata)

### Step 4: Map Fields to Form Inputs

Apply this mapping based on field name and type:

```
Type Mapping:
- string                   --> text input
- string (email pattern)   --> email input
- string (url pattern)     --> url input
- string (password)        --> password input (with show/hide toggle)
- string (phone)           --> tel input
- string (multiline/text)  --> textarea
- string (color)           --> color input
- number / integer         --> number input (with min/max/step)
- boolean                  --> checkbox or toggle switch
- Date / datetime          --> date or datetime-local input
- enum / union of literals --> select dropdown or radio group (radio if <=4 options)
- array of primitives      --> multi-select or tag input
- array of objects         --> repeatable field group (add/remove buttons)
- file / File / Blob       --> file upload input (with drag-and-drop zone)
- nested object            --> fieldset with nested fields

Name-based overrides:
- *password*, *secret*     --> password input
- *email*                  --> email input
- *phone*, *mobile*, *tel* --> tel input
- *url*, *website*, *link* --> url input
- *description*, *bio*, *content*, *body*, *notes* --> textarea
- *avatar*, *image*, *photo*, *logo* --> file upload (image accept)
- *color*, *colour*        --> color picker
- *country*, *state*, *city* --> select with search/autocomplete
- *agree*, *accept*, *terms* --> checkbox
- *gender*, *role*, *status*, *type*, *category* --> select or radio group
- *date*, *dob*, *birthday* --> date input
- *start*, *end* + *date/time* --> datetime-local input
```

### Step 5: Generate Form Component

#### React (React Hook Form + Zod)

Generate a form component file:

```
Component structure:
1. Import statements (react-hook-form, zod resolver, UI components)
2. Props interface:
   - onSubmit: (data: FormData) => Promise<void> | void
   - defaultValues?: Partial<FormData>
   - isLoading?: boolean
   - submitLabel?: string
   - onCancel?: () => void
3. Component function:
   - useForm() with zodResolver and defaultValues
   - handleSubmit wrapper with error handling
   - Each field rendered with:
     a. Label (generated from field name: camelCase -> "Camel Case")
     b. Input component (matching the field type)
     c. Error message display (from form errors)
     d. Helper text (from field description if available)
     e. Required indicator (*) for required fields
   - Submit button with loading state (spinner + disabled)
   - Cancel button if onCancel is provided
   - Form-level error display for server errors
4. Export the component and its props type
```

If shadcn/ui is detected, use its Form, FormField, FormItem, FormLabel, FormControl, FormMessage components.

If Tailwind is detected, use Tailwind utility classes for styling. Otherwise, generate a companion CSS module.

#### Vue (VeeValidate or FormKit)

Generate a Single File Component (.vue):

```
<script setup lang="ts">:
1. Import vee-validate (useForm, useField) or FormKit
2. Define props (modelValue, loading, submitLabel)
3. Define emits (submit, cancel)
4. Setup form with validation schema
5. Define field bindings

<template>:
1. <form @submit="onSubmit">
2. For each field:
   a. <div class="form-field">
   b. <label> with for attribute
   c. Input component bound to field
   d. <span class="error"> for error message
3. Submit/Cancel buttons with loading state
4. </form>

<style scoped>:
- Form layout styles (or Tailwind classes in template)
```

If Vuetify is detected, use v-text-field, v-select, v-checkbox, etc.
If FormKit is detected, use FormKit's declarative schema approach.

#### Svelte

Generate a Svelte component (.svelte):

```
<script lang="ts">:
1. Props: onSubmit, defaultValues, isLoading
2. Form state using writable stores or $state (Svelte 5 runes if detected)
3. Validation logic (manual or using a validation library)
4. Error state management
5. Submit handler with validation

Markup:
1. <form on:submit|preventDefault={handleSubmit}>
2. Each field with label, input, error message
3. Submit button with loading state

<style>:
- Scoped styles for form layout
```

### Step 6: Generate Supporting Files

**Validation Schema** (if not already existing):
- If the source was a raw type (not a Zod/Yup schema), generate the validation schema file using the same logic as the `/gen/validator` skill.
- Import this schema in the form component for client-side validation.

**Types file** (if needed):
- Export the form data type
- Export the form props type

### Step 7: Accessibility

Ensure the generated form includes:
- `<label>` elements with `htmlFor`/`for` attributes linked to input `id`s
- `aria-invalid` on fields with errors
- `aria-describedby` linking inputs to their error messages
- `aria-required` on required fields
- `role="alert"` on error messages
- Proper `type` attributes on inputs
- `autocomplete` attributes where applicable (name, email, tel, address, etc.)
- Focus management: auto-focus first field on mount, focus first error field on failed submit
- Keyboard navigation: Enter to submit, Escape to cancel

### Step 8: File Placement

Place the generated form component following the project's conventions:
- React: `components/forms/<TypeName>Form.tsx` or `components/<TypeName>Form.tsx`
- Vue: `components/forms/<TypeName>Form.vue`
- Svelte: `components/forms/<TypeName>Form.svelte` or `lib/components/forms/`
- Match the existing project directory pattern for components

### Step 9: Summary

Print:
1. Generated component file path
2. Framework and form library used
3. UI component library used (or plain HTML/Tailwind)
4. Number of fields generated with their input types
5. Validation schema file path (if generated)
6. Any dependencies that need to be installed
7. Example usage snippet:
```tsx
// Example for React:
import { UserForm } from './components/forms/UserForm';

function CreateUserPage() {
  const handleSubmit = async (data) => {
    await api.createUser(data);
  };
  return <UserForm onSubmit={handleSubmit} submitLabel="Create User" />;
}
```
