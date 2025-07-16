Changelog
All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog,
and this project adheres to Semantic Versioning.

[1.3.0] - 2024-07-15
✨ Added
Time-Travel Controller: Introduced TimeTravelQuantumWidgetController with undo(), redo(), and travelTo() capabilities.

Time-Travel Debugger: Added a floating visual debugger widget to inspect and navigate the command history.

Magnetic Items (Sticky Headers): Added isMagnetic property to QuantumEntity to create sticky headers.

Layout Morphing: Implemented smooth animated transitions between list and grid modes using AnimatedSwitcher.

Drag & Drop Reordering: Added isReorderable property to QuantumList for easy list item reordering.

Smart Pagination: Introduced PaginatedQuantumListController for effortless infinite scrolling.

Swipe Actions: Added QuantumSwipeAction widget to enable swipe-to-reveal actions on any widget.

New Choreography Types: Added spiral and distanceFromCenter choreography types for more dynamic animations.

.atom() Extension: Added the .atom() extension method on Widget for a cleaner way to achieve atomic updates.

🐛 Fixed
Time-Travel insert Bug: Fixed a critical RangeError during undo operations by correcting the insert method in QuantumWidgetController to perform a real insert instead of redirecting to add.

Swipe Action Animation: Re-architected the animation logic in QuantumSwipeAction for smooth and predictable snapping.

Border Painter Decoupling: Decoupled QuantumBorderPainter from AnimationController by passing a simple double? value, making it more robust.

Magnetic Header Positioning: Correctly accounted for list padding when calculating sticky header positions.

Controller Imports: Cleaned up controller imports by using a new barrel file (controllers.dart).

♻️ Changed
Border System Architecture: Massively simplified QuantumBorderController. It no longer tracks widget positions, only the mapping between border IDs and target entity IDs, making it more efficient and reliable.

Controller Inheritance: FilterableQuantumListController and PaginatedQuantumListController now correctly extend from the appropriate base controllers, resolving inheritance and method assignment issues.

[1.0.0] - 2024-01-01
Initial release of the QuantumList package.

Core Features: QuantumList widget, QuantumWidgetController, FilterableQuantumListController, basic animations, and the Quantum Border system.