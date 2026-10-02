# Screen Design Notes

## Sign in and registration

Use a welcoming MUSE brand mark, a short value statement, labeled email/password fields, a password visibility control, and one clear primary action. Validate missing or malformed fields inline. Keep the switch between sign-in and registration easy to find.

## Home dashboard

Greet the user by name when available. Feature outfit recommendations as the main inspiration action, then show four scannable destinations: wardrobe, outfits, planner, and packing lists. Keep logout available in the app bar.

## Wardrobe

Show the item count and clothing pieces in readable cards. Each item should show its name and useful details such as category, color, and season. The empty state should invite the user to add a first piece. Keep add-item access visible.

## Add wardrobe item

1. Start with an optional photo area offering camera and gallery, plus preview, change, and remove actions.
2. Group the fields under “Item details”: required name, category, color, and best season.
3. Use multi-select occasion chips so one item can fit casual, work, formal, sport, or travel contexts.
4. Keep notes optional and make the save action easy to reach.
5. Show inline name validation, a saving state, and a short confirmation or friendly recovery message.

## Outfit browsing and creation

Show saved looks as cards with outfit name, occasion/season, and number of pieces. For creation, ask for a name, optional occasion and season, then show wardrobe pieces with a visible selected count. Prevent saving until the required name and at least one piece are provided.

## Outfit planner

Make the selected date prominent. Show the planned look for that date, offer a clear action to plan or change an outfit, and confirm before removing a plan. In an empty state, give the user a direct “Plan an outfit” action.

## Packing lists and checklist

Make trip name and date range easy to scan. In trip setup, show saved outfits with their occasion and a selected count. In checklist details, show completion progress and let users mark items packed without exposing database identifiers.

## Recommendations

Keep occasion and season filters optional, make reset easy, and show the actual names and categories of the recommended wardrobe pieces. Empty results should suggest changing a filter or adding items.
