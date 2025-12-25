# Smart Groceries

The "Smart Groceries" feature introduces record types, smart text parsing for quantities and prices, and logic to automatically find the best prices for your grocery items.

## Text Syntax

Tigidou uses special prefixes to identify different types of data within your records:

| Prefix | Type | Example | Description |
| :--- | :--- | :--- | :--- |
| `!` | Record Type | `IGA !store.groceries` | Identifies the record type. Can include a category. |
| `@` | Mention | `@HomeDepot` | Links a record to a person or place. Use CamelCase for multi-word names. |
| `#` | Group | `#groceries` | Organizes records and triggers smart lookups. |
| `$` | Price | `$4.50` | Specifies a monetary value (shortcut). |
| `@$` | Price | `@$4.50` | Alternative price syntax via @ mention. |
| `@price:` | Price | `@price:4.50` | Explicit price attribute (with or without `$`). |
| `[n]x` | Quantity | `2x` | Specifies a quantity (also supports `qty:2`, `2qty`). |

> [!NOTE]
> **Price Shortcuts**: All three price syntaxes are equivalent:
> - `$15.00` — must be followed only by digits, periods, or commas
> - `@$15.00` — the `@` prefix with `$` immediately after
> - `@price:15.00` or `@price:$15.00` — explicit attribute syntax

## Feature: Best Price Lookup

Tigidou uses a dynamic mapping system to find the best prices for your items. When you add a hashtag like `#groceries` to an item, it looks for stores defined with the corresponding category.

### 1. Link a Store to a Category
Use the `!store.CATEGORY` syntax to define a shop's specialty:
`IGA !store.groceries`
`Home Depot !store.hardware`

### 2. Record Prices for that Store
Add records that mention the store and include a price:
`Milk @IGA $4.50`
`Hammer @HomeDepot $15.00`

### 3. Add Items to your List
When you add an item with a category tag, Tigidou will find the best price from the linked stores:
`Milk #groceries` -> Will lookup prices from `@IGA` (linked via `!store.groceries`).
`Hammer #hardware` -> Will lookup prices from `@HomeDepot` (linked via `!store.hardware`).

### Result:

Tigidou will display a "Best Price" badge below the item:
`⭐ Best: $4.25 at Costco`

## Feature: Panel Views

Tigidou provides specialized "Panel Views" accessible from the Dashboard. These views group records by context and strip redundant information for a cleaner display.

### Contextual Tag Stripping

When you view a record inside a specific Panel, the tag that defines that panel is automatically hidden from the title.

*   **Store Panel**: Records with `!store` or `!store.CATEGORY` are displayed here. The `!store` tokens are hidden.
    *   *Input*: `IGA !store.groceries`
    *   *Display in Panel*: `IGA`
*   **Categories (e.g., Groceries)**: Records with a specific hashtag (e.g., `#groceries`) are displayed here. The hashtag is hidden.
    *   *Input*: `Milk #groceries`
    *   *Display in Panel*: `Milk`

## Auto-Suggestions

When typing `!`, `@`, or `#` in the search/add bar, Tigidou provides intelligent suggestions based on your existing records and common types to help you stay consistent.
