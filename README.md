# 🚀 QuantumList: The Revolutionary Flutter List Widget 🚀

**A hyper-performance, feature-rich, and beautifully animated list widget for Flutter that enables atomic rendering, advanced state management, and stunning UI effects with minimal effort.**

---
<p align="center">
  <img src="https://placehold.co/800x400/1E1E1E/FFFFFF?text=Your+Awesome+Project+GIF+Here" alt="Project Demo GIF"/>
</p>

### **[Check out the Live Demo!](https://shoghshahadat.github.io/QuantumList/)** | **[فارسی](https://github.com/ShoghShahadat/QuantumList/blob/main/Fa.md)**
---

## 1. Why Does QuantumList Exist?

In the world of Flutter, building dynamic lists is fundamental. But as lists grow in complexity, developers face painful challenges:
- **Unnecessary Rebuilds:** Calling `setState` to update one item forces the entire list to rebuild, causing jank and performance bottlenecks.
- **State Management Hell:** Managing a list with different item types (like a news feed) requires complex state management logic and boilerplate.
- **Animation Complexity:** Implementing beautiful, coordinated animations often means wrestling with `AnimatedList`, `TickerProvider`s, and complex calculations.

**QuantumList was built to solve these problems.** It provides a radically new architecture that makes building complex, high-performance, and visually stunning lists not just possible, but *easy*.

---

## 2. The Quantum Advantage: A New Reality for Lists

| Feature | Standard `ListView`/`GridView` | `QuantumList` | **The Game-Changing Advantage** |
| :--- | :--- | :--- | :--- |
| **Rebuild Strategy** | Often requires `setState` on the parent, rebuilding many items. | **Atomic Updates:** Rebuilds only the specific widget that changed. | ✅ **Blazing-fast performance.** Update a live stock ticker in a list of 1000 items without any lag. |
| **State Management** | Requires external state management (Provider, BLoC) for complex lists. | **Dual Controller Architecture:** Built-in, powerful controllers for any use case. | ✅ **Drastically simplified logic.** Manage a complex news feed with ads and articles as easily as a simple list. |
| **Item Animation** | Requires manual setup with `AnimatedList` and complex controllers. | **Built-in Animation & Choreography:** Rich library of animations and choreography. | ✅ **Cinematic UI in minutes.** Create wave or staggered animations with a single line of code. |
| **Advanced Features** | Requires multiple packages and custom code for undo/redo, sticky headers, etc. | **All-in-One:** Time-travel, magnetic items, layout morphing, pagination, and more. | ✅ **Develop faster with a cleaner codebase.** Stop hunting for packages; the power is already here. |
| **Widget Heterogeneity** | Managing lists of different widget types can be cumbersome. | **Widget-ID Controller:** Effortlessly manage lists of diverse widgets using unique IDs. | ✅ **The ultimate tool for modern UIs.** Perfect for feeds, dashboards, and dynamic content. |

---

## 3. The Quantum Principles: Core Concepts Explained

To truly harness the power of QuantumList, it's essential to understand its core principles.

### ⚛️ Principle #1: Atomic Rendering

This is the heart of QuantumList's performance. Traditionally, when you update an item in a list, you might call `setState()` on the parent widget, causing every item in the viewport to rebuild. This is incredibly inefficient.

**QuantumList solves this with the concept of the Atom.**

An "Atom" is the smallest possible unit of your UI that should rebuild when its specific data changes. QuantumList ensures that when you call `controller.update()`, only the corresponding `QuantumAtom` for that single item rebuilds, leaving everything else untouched.

**How it Works:**
The `QuantumListController` maintains a stream (`updateStream`). When you call `update(id, newWidget)`, the controller finds the index of that item and pushes *only that index* into the stream. Internally, each item in the `QuantumList` is wrapped in a `StreamBuilder` that listens to this stream but *filters* for its own *index*. This means only the widget that is meant to be updated will react.

### ✨ Deep Dive: The `.atom()` Extension Method

While you can manually set up a `StreamBuilder` to listen for updates, QuantumList provides a much more elegant solution: the `.atom()` extension method.

**What is it?**
`.atom()` is a convenience extension method on `Widget`. It's a clean wrapper around the `StreamBuilder` logic described above. Its only job is to listen to the controller's update stream and rebuild the widget it's attached to if, and only if, the update is for its specific index.

**Why should you use it?**
It makes your code cleaner, more readable, and less error-prone. It clearly signals your intent: "This widget should be atomically aware."

**Let's see the difference:**

**Before (The Manual Way):**
```dart
// In your animationBuilder:
animationBuilder: (context, index, entity, animation) {
  // Manually wrapping with a StreamBuilder to handle atomic updates.
  // This is verbose and can be forgotten.
  return StreamBuilder<int>(
    stream: _controller.updateStream.where((updatedIndex) => updatedIndex == index),
    builder: (context, snapshot) {
      // Now we build the actual widget
      return QuantumAnimations.scaleIn(context, entity.widget, animation);
    }
  );
}
```

**After (The Elegant `.atom()` Way):**
```dart
// In your animationBuilder:
animationBuilder: (context, index, entity, animation) {
  // Apply the animation, then make it atomically aware. Clean and simple.
  return QuantumAnimations.scaleIn(context, entity.widget, animation)
      .atom(_controller, index);
}
```
As you can see, `.atom()` abstracts away the boilerplate, leaving you with a single, declarative line. It's the recommended way to ensure your widgets participate in the atomic rendering system.

### 👑 Principle #2: The Dual Controller Architecture

There is no one-size-fits-all solution for list management. QuantumList acknowledges this by providing two distinct, powerful controller types.

| Controller | `QuantumWidgetController` (The Revolutionary) | `FilterableQuantumListController<T>` (The Classic) |
| :--- | :--- | :--- |
| **Core Idea** | Manage a list of `Widget`s directly using unique `String` IDs. | Manage a list of structured `Data Model`s (e.g., `User`, `Product`). |
| **Best For** | **Heterogeneous Lists:** News feeds, dashboards, settings pages, any UI with mixed content. | **Homogeneous Lists:** Lists of users, products, emails, anything with a consistent data structure. |
| **Strengths** | Extreme flexibility, no need for data models, perfect for dynamic UIs. | Built-in high-performance filtering and sorting, type safety. |
| **When to Use** | When your UI is a collection of disparate components. | When your UI is a direct representation of a list of data. |

---

## 4. A Universe of Features at Your Fingertips

QuantumList is more than a list; it's a complete ecosystem for building dynamic UIs. Here's a quick look at how to enable its most powerful features.

* **🎬 Advanced Animation & Choreography:** Bring your list to life with stunning, coordinated entrance animations.
  ```dart
  QuantumList(
    // This one line creates a beautiful wave effect!
    choreography: QuantumChoreography.wave(),
    animationDuration: const Duration(milliseconds: 1200),
    ...
  );
  ```

* **✨ Quantum Borders:** Make your items pop with dynamic, animated borders.
  ```dart
  // 1. Create and connect a border controller
  final _borderController = QuantumBorderController();
  QuantumList(borderController: _borderController, ...);
  
  // 2. Add a dazzling, animated gradient border to a specific item
  _borderController.addBorder(
    borderId: "highlight_border",
    targetEntityId: "item-to-highlight",
    border: QuantumBorder.animatedGradient(),
  );
  ```

* **👽 Layout Morphing:** A touch of magic. Seamlessly animate between a list and a grid.
  ```dart
  // Just change the 'type' property and QuantumList handles the animation!
  QuantumList(
    key: ValueKey(_listType), // Use a key to trigger the animation
    type: _listType, // Can be QuantumListType.list or QuantumListType.grid
    ...
  );
  ```

* **🧲 Magnetic Items (Sticky Headers):** Never lose context.
  ```dart
  // Simply flag an entity as magnetic to make it a sticky header
  _controller.add(
    QuantumEntity(id: "header-a", widget: SectionHeader(title: "Section A"), isMagnetic: true)
  );
  ```

* **⏳ Time-Travel (Undo/Redo):** Never make a mistake again.
  ```dart
  // 1. Use the TimeTravel controller
  final _controller = TimeTravelQuantumWidgetController();
  
  // 2. Add Undo/Redo buttons
  ElevatedButton(onPressed: _controller.undo, child: Text("Undo"));
  ```

* **👆 Drag & Drop Reordering:** Intuitive user interaction.
  ```dart
  QuantumList(
    // It's that simple.
    isReorderable: true,
    ...
  );
  ```

* **📜 Smart Pagination:** For infinite lists.
  ```dart
  // The controller handles the logic of fetching pages as the user scrolls
  final _controller = PaginatedQuantumListController<Product>(
    (page) => fetchProductsFromApi(page), // Your API fetching function
    loadingIndicator: Center(child: CircularProgressIndicator()),
  );
  ```

* **↔️ Swipe Actions:** Clean and modern UX.
  ```dart
  // Wrap any widget to make it swipeable
  QuantumSwipeAction(
    rightActions: [ /* Delete Action */ ],
    leftActions: [ /* Archive Action */ ],
    child: MyEmailListItem(),
  );
  ```

---

## 5. Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  quantum_list: ^1.3.0 # Replace with the latest version
```

Then, install it by running:
```shell
flutter pub get
```

---

## 6. Mastering QuantumList: Practical Examples

### The Revolutionary Widget-ID Approach (Example: A Dynamic News Feed)

```dart
// 1. Create the controller
final _feedController = QuantumWidgetController();

// 2. Build the UI, using .atom() for efficiency
QuantumList<QuantumEntity>(
  controller: _feedController,
  animationBuilder: (context, index, entity, animation) {
    return QuantumAnimations.slideInFromBottom(context, entity.widget, animation)
        .atom(_feedController, index); // Make it atomic!
  },
);

// 3. Dynamically manage the feed from anywhere in your app
void addBreakingNews() {
  final newsId = "news_${DateTime.now().millisecondsSinceEpoch}";
  _feedController.add(
    QuantumEntity(id: newsId, widget: BreakingNewsCard(headline: "QuantumList Takes Over!"))
  );
}
```

### The Classic Data-Model Approach (Example: A Filterable User List)

```dart
// 1. Define your model and controller
class User { /* ... */ }
final _userController = FilterableQuantumListController<User>(_users);

// 2. Build the UI
QuantumList<User>(
  controller: _userController,
  animationBuilder: (context, index, user, animation) {
    // Note: .atom() is most impactful with QuantumWidgetController and its `update` method.
    // For FilterableQuantumListController, the whole list structure often changes,
    // but using .atom() is still a good practice for potential future property updates.
    return UserCard(user: user).atom(_userController, index);
  },
);

// 3. Filter and sort with ease
_userController.filter((user) => user.name.startsWith('A'));
_userController.sort((a, b) => a.name.compareTo(b.name));
```

---

## 7. The Quantum Codex: Complete API Reference

### `QuantumList<T>` Widget

| Property | Type | Description |
| :--- | :--- | :--- |
| `controller` | `QuantumListController<T>` | **Required.** The controller that manages the list's state. |
| `animationBuilder`| `Function` | **Required.** A builder that returns a widget for a given item and its entrance animation. |
| `type` | `QuantumListType` | The layout type: `.list` (default) or `.grid`. |
| `gridDelegate` | `SliverGridDelegate` | Required when `type` is `.grid`. |
| `isReorderable` | `bool` | Enables drag & drop reordering of items. Default is `false`. |
| `choreography` | `QuantumChoreography` | Defines the animation sequence for items (e.g., `QuantumChoreography.wave()`). |
| `borderController` | `QuantumBorderController` | Connects the Quantum Border system to the list. |
| `scrollController` | `ScrollController` | An optional external scroll controller. |
| `animationDuration`| `Duration` | The duration of the entrance/exit animations. Default is 400ms. |
| `padding` | `EdgeInsetsGeometry` | Padding for the list content. |
| `physics` | `ScrollPhysics` | The scroll physics for the list. |
| `reverse` | `bool` | Whether the list scrolls in the reverse direction. |
| `scrollDirection`| `Axis` | The axis along which the list scrolls. |

### Controller Methods

#### `QuantumWidgetController`
| Method | Description |
| :--- | :--- |
| `add(QuantumEntity entity)` | Adds a widget entity to the end of the list. |
| `remove(String id)` | Removes a widget entity by its unique ID. |
| `update(String id, Widget newWidget)` | Atomically updates the widget for a given ID. |
| `getById(String id)` | Retrieves a `QuantumEntity` by its ID. |
| `scrollTo(String id, ...)`| Animates the scroll position to the widget with the given ID. |
| `clear()` | Removes all items from the list. |

#### `FilterableQuantumListController<T>`
| Method | Description |
| :--- | :--- |
| `filter(bool Function(T)? test)` | Filters the list based on the test function. Pass `null` to clear the filter. |
| `sort(int Function(T, T) compare)` | Sorts the master list and reapplies the current filter. |
| `add(T item)` | Adds an item to the master list and the filtered list if it passes the filter. |
| `removeAt(int index)` | Removes an item from the visible list and the master list. |

#### `TimeTravelQuantumWidgetController`
| Method | Description |
| :--- | :--- |
| `undo()` | Reverts the last list modification (add, remove, or update). |
| `redo()` | Re-applies the last undone modification. |
| `travelTo(int commandIndex)` | Jumps to a specific state in the command history. |
| `canUndo` / `canRedo` | `bool` getters to check if undo/redo is available. |
| `historyStream` | A stream that emits an event whenever the history changes. |

---

## 8. Join the Revolution

QuantumList is more than a package; it's a new way of thinking about UIs in Flutter. It's designed to be powerful, flexible, and a joy to use.

-   ⭐ **Star the repo** to show your support!
-   🤔 **Explore the `example` app** to see every feature in action.
-   💡 **Create an issue** to report bugs or suggest amazing new features.

Happy coding, and may your lists be ever dynamic and beautiful!
