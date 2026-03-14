# Build Multi-Step Form Wizard

Generate a multi-step form wizard with validation, navigation, data persistence, and a review step.

## Arguments

$ARGUMENTS - `<steps-description>` a description of the form steps (e.g., "personal info, address, payment, review" or "step1:Name+Email step2:Address step3:Preferences")

## Instructions

1. Parse the steps description to identify:
   - Number of steps
   - Fields for each step (infer reasonable fields if only step names are given)
   - Field types (text, email, phone, select, checkbox, date, file, etc.)
   - Which fields are required vs optional

2. Detect the project's framework and form library:
   - React: Check for `react-hook-form`, `formik`, or `@tanstack/react-form`
   - Vue: Check for `vee-validate` or `vuelidate`
   - If no form library is found, use the most popular for the framework (react-hook-form for React, vee-validate for Vue)
   - Check for validation libraries: `zod`, `yup`, `joi`

3. Create the form wizard structure:

### Wizard Container Component
   - Manages current step state
   - Stores form data across all steps in a single state object
   - Handles step navigation (next, previous, go to step)
   - Prevents navigation to future steps unless current step is valid
   - Allows navigation to previous steps freely
   - Submits the complete form data on the final step

### Progress Indicator Component
   - Visual step indicator (numbered circles connected by lines, or breadcrumb style)
   - Shows: completed steps (checkmark), current step (highlighted), upcoming steps (dimmed)
   - Step labels visible on desktop, numbers only on mobile
   - Clickable completed steps to navigate back
   - Accessible: uses `aria-current="step"` for current step, `role="list"` for step list

### Step Components (one per step)
   - Each step is a separate component receiving form data and update handlers
   - Step-level validation schema (validates only the fields in that step)
   - Fields render with labels, placeholders, helper text, and error messages
   - Auto-focus first field when step becomes active
   - Preserve field values when navigating between steps

4. Implement validation per step:
   - Create a validation schema for each step using Zod (preferred) or Yup:
     ```
     Step 1 schema validates only step 1 fields
     Step 2 schema validates only step 2 fields
     Full schema = merge of all step schemas (for final submission)
     ```
   - Validate on field blur (show errors immediately)
   - Validate entire step on "Next" button click
   - Block navigation to next step if validation fails
   - Show inline error messages below each field
   - Highlight invalid fields with error border color

5. Implement navigation:
   - **Back button**: Always enabled (except on step 1). No validation needed to go back.
   - **Next button**: Validates current step. If valid, advances to next step. If invalid, shows errors.
   - **Step indicator clicks**: Can go to any completed step. Cannot skip ahead to uncompleted steps.
   - **Submit button**: Appears on the review step (or last step). Validates all data before submission.
   - **Keyboard**: Enter key advances to next step (if on last field of step). Tab moves between fields naturally.

6. Implement data persistence between steps:
   - Store form data in component state (React: useState/useReducer, Vue: reactive/ref)
   - Optionally persist to sessionStorage to survive page refreshes:
     - Save to sessionStorage on every field change (debounced)
     - Load from sessionStorage on mount
     - Clear sessionStorage on successful submission
   - Each step component receives the full form data and its own update function

7. Create a Review Step:
   - Display all collected data in a read-only summary format
   - Group data by step (with step names as section headers)
   - Show field labels and their values in a clean layout
   - Sensitive data (passwords, SSN) should be masked with option to reveal
   - "Edit" button next to each section to jump back to that step
   - Final "Submit" button with loading state
   - Confirm dialog before submission (optional)

8. Implement the submit handler:
   - Validate all data against the complete schema one final time
   - Show loading state on submit button (spinner, disabled)
   - Handle success: show success message, clear form, redirect or close
   - Handle error: show error message, keep form data, allow retry
   - Prevent double submission

9. Add keyboard navigation:
   - Tab moves between form fields naturally
   - Enter on the last field of a step triggers "Next"
   - Escape closes any open dropdowns or modals
   - Arrow keys work in radio groups and select fields

10. Style the wizard:
    - Responsive layout (single column on mobile, wider on desktop)
    - Clear visual hierarchy
    - Visible focus states on all interactive elements
    - Error states use color + icon (not color alone)
    - Loading/disabled states are visually distinct
    - Smooth transitions between steps (fade or slide)

11. Create types/interfaces:
    - Form data type (all fields across all steps)
    - Step configuration type (step name, fields, validation schema)
    - Step status type (completed, current, upcoming)

12. Print a summary of created files, the form structure, and usage instructions.
