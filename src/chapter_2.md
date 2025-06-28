# Chapter 2: Early Implementation and First Pivot

As I dove deeper into building Praxis Forge, the gap between vision and implementation began to reveal itself. This chapter covers my first major strategic decision: abandoning Yew in favor of Leptos, and what that taught me about framework selection in emerging ecosystems.

## The Yew Experience

Working with Yew was my introduction to Rust-based web development, and it came with a unique set of challenges:

### The Good

- **Familiar Patterns**: The component model felt similar to React, making the transition conceptually smooth
- **Type Safety**: Rust's type system caught errors at compile time that would have been runtime bugs in JavaScript
- **Performance Potential**: WebAssembly promised optimized performance for complex operations

### The Friction

- **Verbose Boilerplate**: Simple components required significantly more code than their React equivalents
- **Callback Hell**: Managing callbacks between components involved complex boxing and lifetime management
- **Build Times**: Even small changes required lengthy build cycles
- **Error Messages**: Type errors were often overwhelming and difficult to trace back to the actual problem

## Discovering Leptos

While researching solutions to some of Yew's pain points, I discovered Leptos—a newer framework that promised to solve many of the issues I was experiencing:

### Key Advantages

- **Reduced Boilerplate**: Components were more concise and closer to modern React patterns
- **Fine-Grained Reactivity**: Instead of virtual DOM diffing, Leptos used signals for targeted updates
- **Better Performance**: Both compile-time and runtime performance improvements
- **Modern Patterns**: Felt more aligned with current frontend development practices

### The Decision to Pivot

This was my first major strategic decision in the project. I had already invested weeks in Yew-based components, but the productivity gains from Leptos were too significant to ignore.

**Decision Criteria:**

- **Developer Experience**: Leptos felt more productive for rapid iteration
- **Community**: While smaller, the Leptos community was highly engaged
- **Performance**: Both frameworks compiled to WebAssembly, but Leptos had better optimization
- **Future-Proofing**: Leptos appeared to be gaining momentum in the Rust web ecosystem

## The Migration Process

Migrating from Yew to Leptos taught me valuable lessons about code organization and framework abstractions:

### What Transferred Easily

- **Business Logic**: Pure Rust functions moved without changes
- **Data Models**: Struct definitions and serialization code remained identical
- **Styling**: CSS and design systems were framework-agnostic

### What Required Rewriting

- **Component Structure**: Leptos components used different patterns for props and state
- **Event Handling**: Callback patterns were simpler but required learning new approaches
- **Routing**: Different routing paradigms required rethinking navigation logic

### The Praxis Shop v2 Result

The migration resulted in what I called "Praxis Shop v2"—a more focused implementation that concentrated on the core goals and tasks functionality rather than the full five-component vision.

**Key Characteristics:**

- Maintained Tauri for desktop packaging
- Continued with the Elixir backend plan
- Focused scope to just goal and task management
- Cleaner, more maintainable codebase

## Early Wins and Continued Challenges

The Leptos migration provided immediate benefits:

### Improvements

- **Faster Development**: Component creation was significantly quicker
- **Cleaner Code**: Less boilerplate meant more focus on business logic
- **Better Debugging**: Error messages were more actionable
- **Improved Builds**: Though still slower than JavaScript, builds were noticeably faster

### Persistent Issues

- **Integration Complexity**: Connecting to the Elixir backend still required solving complex serialization and state management problems
- **CSS Challenges**: Framework-specific styling patterns were inconsistent
- **WebAssembly Limitations**: Browser API access remained cumbersome
- **Testing Difficulties**: Setting up proper testing infrastructure was still complex

## Lessons from the First Pivot

This early pivot taught me several crucial lessons that would influence later decisions:

### Framework Selection Matters Long-Term

Early technical choices have compounding effects over months of development. The decision to switch frameworks after several weeks of investment was painful but ultimately beneficial.

### Developer Experience is Critical

When you're building complex software, the speed of the development iteration cycle directly impacts your ability to solve problems and implement features effectively.

### Be Willing to Question Assumptions

Just because I had made an initial technology choice didn't mean I was locked into it. Being willing to pivot based on evidence led to better outcomes.

### Document Everything

Keeping detailed notes about why I made the pivot, what worked and what didn't, proved invaluable for future decisions.

## Setting Up Future Challenges

While the Leptos migration solved immediate developer experience issues, it also set up the next phase of challenges. I was still committed to:

- Complex integration with the Elixir backend via GraphQL
- Building a comprehensive multi-component system
- Packaging as a desktop application with Tauri

These ambitious goals would soon collide with the realities of modern web development, leading to even more significant architectural decisions.

The success of the Leptos migration gave me confidence that strategic pivots could solve technical problems. This mindset would prove crucial as the challenges ahead were far more complex than framework selection.

---

_Next: Chapter 3 examines how ambitious integration plans led to "integration hell" and the hard lessons learned about complexity management._
