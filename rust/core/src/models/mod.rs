//! Domain models for interactions.work

mod interaction;
mod member;
mod okr;
mod team;

pub use interaction::{Interaction, InteractionKind};
pub use member::Member;
pub use okr::{KeyResult, Objective, OkrVisibility};
pub use team::Team;
