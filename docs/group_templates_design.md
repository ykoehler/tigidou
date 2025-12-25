# Design: Dynamic Group Templates

## Overview
This document outlines the design for a user-definable templating system for groups in Tigidou. Templates allow users to customize the visual representation and interaction model of records belonging to specific groups (hashtags), without hardcoding logic in the app's codebase.

## Core Concepts

### 1. Types as Schemas (Entity Definitions)
Record types (starting with `!`) act as structural definitions. When a record defines a type (e.g., `IGA !store.grocery`), the main text ("IGA") becomes the **Identifier**. 
- **Constraint**: Identifier records (entity definitions) are "pure" and do not support auxiliary fields like dates, times, or reminders. They represent the "master data" or schema.

### 2. Groups as Collections
Hashtags (starting with `#`) define groups. A group is a collection of records that share a common tag. Groups aggregate both tasks and entity definitions.

### 3. Templates as Meta-Records
A **Template** is a special record that defines how a group should be rendered. 
- **Trigger**: A template is applied when a record has a specific hashtag (e.g., `#groceries`) and there exists a template record associated with that hashtag.
- **Record Type**: Templates use the reserved record type `!template` or `!group.template`.

## Data Structure

A template is stored as a standard record with a specific configuration.

```json
{
  "title": "Grocery Shopping Template",
  "tags": ["groceries"],
  "recordType": "template",
  "config": {
    "layout": "list",
    "primaryRow": ["title", "quantity:right"],
    "secondaryRow": ["price", "suggest:!store.grocery"],
    "showDefaultTools": false,
    "cascadeToDefault": "more..."
  }
}
```

## Recursive Design: Meta-Templates (Self-Hosting)

A powerful aspect of this design is that the system is **self-hosting**. The specialized UI used to edit a template is itself a template defined for the `!template` record type.

### 1. The Build-in Meta-Template
The app comes with a built-in, read-only template for the `!template` type.
- **Trigger**: `!template`
- **Definition**: `{ layout: 'editor', primaryRow: ['title:name'], secondaryRow: ['config:code_block'] }`

### 2. User Visibility
Users can "see" this meta-template (e.g., by searching for `!template` or looking at system records). 
- It serves as a living documentation of how the template editor is structured.
- For now, this core meta-template is **read-only** to prevent users from accidentally "breaking" the interface they use to create other templates.

### 3. Consistency
By treating the template builder as just another templated view, we ensure that:
- The parser logic remains consistent.
- Future improvements to the "Code Editor" widget or "Name Field" automatically benefit the template builder.
- The system remains "recursive"—everything the user sees is driven by the record + template relationship.

## Storage vs. Presentation

To maintain the simplicity of the existing record design while providing a specialized editing experience, templates use a **Dual-Layer Representation**.

### 1. Database Layer (Single Line)
Templates are stored as standard records. Everything (Name, Tag, Type, and Definition) is preserved in a single string.
- **Format**: `[Name] #[Group] !template { [Definition] }`
- **Example**: `Grocery List #groceries !template { layout: 'row', fields: ['title', 'qty:right'] }`

### 2. Visual Layer (Separated UI)
When the app detects a record of type `!template`, it presents a specialized "Template Builder" view instead of a standard text field:
- **Name Field**: Edits the leading text of the record.
- **Group Selector**: Manages the hashtag (trigger).
- **Definition Editor**: An interactive area for the `{}` block with autocomplete and validation.

This approach ensures that the database remains "flat" and compatible with all existing synchronization and sharing logic, while the user enjoys a structured, intuitive interface.

## Template Creation & Discovery

To make template definition intuitive and discoverable, the app implements a **Context-Aware Template Builder**.

### 1. Interactive Autocomplete
When typing within the `{}` block of a `!template`, the suggestion overlay provides:
- **Available Keys**: `layout`, `fields`, `suggest`, `theme`.
- **Predefined Values**: For `layout`, it suggests `'row'`, `'grid'`, `'list'`. For `fields`, it suggests `'title'`, `'qty'`, `'price'`, etc.
- **Modifiers**: After a field name, it suggests `:right`, `:row2`, `:bold`, `:italic`.

### 2. Live Preview
The Template Screen (or the "New Todo" dialog when a template is detected) shows a **Dummy Record Preview** directly below the text field.
- As the user types, the preview updates in real-time.
- Example: "Item Description 3x $10.00" is rendered according to the current template string.

### 3. Real-time Validation
- **Syntax Highlighting**: The template block is highlighted to show valid vs. invalid syntax.
- **Error Feedback**: If the user types an unknown key (e.g., `layot`), the preview is replaced by a helpful error message: *"Unknown key 'layot'. Did you mean 'layout'?"*
- **Field Checks**: Ensuring that mandatory fields (like `title`) aren't missing.

## Template Record Structure

A template record has a clear **Name** (the title) and a **Definition** (the configuration string).

| Field | Description |
| :--- | :--- |
| **Title** | The user-friendly name (e.g., "Grocery Shopping List"). |
| **Tags** | The trigger hashtag(s) (e.g., `#groceries`). |
| **Record Type** | Always `!template`. |
| **Definition** | The string inside `{}` that defines the layout and rules. |

## Rendering Engine Logic

When the app encounters a group (e.g., in a list or search results):

1. **Lookup**: Fetch all records of type `!template`.
2. **Match**: Find the template whose tags intersect with the current group's tags.
3. **Application**:
   - If a match is found, use the template config to build the widget tree for each item in the group.
   - If no match is found, apply the **Default Template**.
4. **Cascading**:
   - Every template can include a "More..." button.
   - Clicking "More..." toggles the rendering to the **Default Template**, showing all standard tools (@date, @person, etc.).

## Visual Example: Groceries Group

**Item:** `Milk 2x $4.50 #groceries`

**Rendering (with Grocery Template):**
```
--------------------------------------------
| Milk                                 2x  |
| $4.50    [ At: !store.grocery ]          |
--------------------------------------------
| [ More... ]                              |
--------------------------------------------
```

**Rendering (after clicking "More..."):**
Standard view showing tags, date picker, people assignment, etc.

## Benefits
- **Extensibility**: Users can create templates for "Work Projects", "Inventory", "Contacts", etc., without developer intervention.
- **Cleanliness**: Hides non-essential complexity for specialized workflows (like shopping) while keeping power-user features accessible via the "More..." cascade.
- **Consistency**: Leverages the existing unified record system (! and #).
