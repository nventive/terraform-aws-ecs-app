# Breaking Changes

## 2.0.0

- The `alb_listeners` now requires a `default_action.type` whenever you are not using `alb_listeners`' default value.
  To use previous default behaviour, use a `default_action.type` of `forward`.
