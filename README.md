# Factorio - Improved Combinator SE

Original Mod was created by [SomeUserName785](https://mods.factorio.com/user/SomeUserName785): [Improved Combinator](https://mods.factorio.com/mod/ImprovedCombinator)

This fork adds compatibility with [Space Exploration](https://mods.factorio.com/mod/space-exploration) by allowing the Improved Combinator to be placed in space.

## Mod description
This mod aims to provide a way to easily manage multiple combinators and time conditions in a single GUI similarly to the train scheduler.

### Combinators
The Combinators tab allows for the creation of the standard Factorio combinators (decider & arithmetic) and new custom combinator.

#### Callable Timer Combinator
This is a new custom combinator which checks if a condition is met and triggers a timer when one is selected

### Timers
The Timers tab can be used to create custom timers that can check specified combinators at specified intervals. The timer measuring unit is using seconds (60 game ticks) and can be changed by the user.

#### Repeatable timer
Timer which run for a specified time, then run checks for all owned combinators and finally restarts and repeats the process

#### Callable Tick timer
A timer which will check all owned combinators on every tick while running. The timer can only be started using a conditional timer combinator.

#### Callable timer
A timer which will check all owned combinators only after it has finished running. The timer can only be started using a conditional timer combinator.