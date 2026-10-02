# MUSE Design System

## Design direction

MUSE should feel like a calm, personal wardrobe companion: warm, editorial, and easy to scan. Keep clothing and outfit decisions central, and keep supporting actions quiet.

## Color palette

| Token | Hex | Purpose |
| --- | --- | --- |
| Plum | `#70566F` | Primary actions, selected controls, and emphasis |
| Paper | `#FAF7F2` | Main app background |
| Ink | `#29242B` | Primary text and headings |
| Muted | `#746E76` | Supporting text and helper labels |
| Line | `#E8E1E7` | Borders and dividers |
| Blush | `#F2EAF1` | Soft selection and icon surfaces |
| Terracotta | `#B36F58` | Secondary accent |

## Type and layout

- Use a clear hierarchy: large page title, medium section title, concise body copy, and small helper text.
- Prefer sentence case and plain language.
- Use a 4 px spacing base, with 8, 12, 16, 20, and 24 px as common increments.
- Use 20 px card corners and 14–16 px input corners.
- Make primary touch actions at least 48 px high.
- Keep forms scrollable and ensure content remains usable on narrow phone screens.

## Components

- **Primary action:** filled plum button with a verb phrase, such as “Save item” or “Plan an outfit.”
- **Secondary action:** outlined or tonal button for actions such as retry, clear filters, or changing a date.
- **Cards:** white surface, subtle border, generous spacing, and no heavy shadow.
- **Fields:** visible labels, helpful examples, inline validation, and clear focus/error borders.
- **Selection:** chips for multiple occasions; checkboxes for selecting wardrobe pieces or packing items.
- **Feedback:** short success/error messages; do not show raw API or Firebase errors.
- **Empty states:** explain why the screen is empty and offer the next useful action.

## Accessibility

- Pair icons with text or tooltips where their meaning may be unclear.
- Keep text contrast readable and support system text scaling.
- Provide visible field labels and field-level validation.
- Keep touch controls comfortably sized and avoid using color as the only selection signal.
- Describe image controls for assistive technology and make image actions available by touch.
