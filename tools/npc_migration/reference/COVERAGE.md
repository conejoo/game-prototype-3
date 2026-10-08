# Pinned public coverage

Generated from byte-exact source packages. Enabled means eligible for this migration once owning tasks implement it; it does not claim current runtime activation. Original text/conditions/effects remain in coverage.json. Deferred rows retain stable IDs and authored fields.

## npc-01

| Kind | Stable ID | Status | Gates / disclosure / transition |
| --- | --- | --- | --- |
| node | npc-01-initial-conversation | enabled | {"conditions":{"excludedFlags":["npc-01-first-conversation-complete"]},"entry_index":4,"priority":100,"portraitId":"skeptical"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-01-helpful-response | enabled | {"targetNodeId":"npc-01-initial-helpful-end","affinityDelta":1,"oneTime":true,"oneTimeRewardFlag":"npc-01-helpful-reward-applied","addedFlags":["npc-01-first-conversation-complete","npc-01-helpful-response"]}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-01-neutral-response | enabled | {"targetNodeId":"npc-01-initial-guarded-end","affinityDelta":0,"oneTime":true,"oneTimeRewardFlag":"npc-01-neutral-reward-applied","addedFlags":["npc-01-first-conversation-complete","npc-01-neutral-response"]}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-01-initial-helpful-end | enabled | {"entry_index":null,"priority":0,"portraitId":"practiced-smile"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-01-initial-guarded-end | enabled | {"entry_index":null,"priority":0,"portraitId":"official-neutral"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-01-woods-first | enabled | {"conditions":{"requiredFlags":["npc-01-first-conversation-complete"],"unseenNodeIds":["npc-01-woods-first"],"events":[{"kind":"areaEntered","subjectId":"woods","minimumCount":1,"maximumCount":1}]},"entry_index":3,"priority":130,"portraitId":"official-neutral"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-01-woods-repeat | enabled | {"conditions":{"requiredFlags":["npc-01-first-conversation-complete"],"unseenNodeIds":["npc-01-woods-repeat"],"events":[{"kind":"areaEntered","subjectId":"woods","minimumCount":2}]},"entry_index":2,"priority":140,"portraitId":"skeptical"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-01-moonflower-hint | enabled | {"revealedFactIds":["npc-01-moonflower-preference"],"conditions":{"requiredFlags":["npc-01-first-conversation-complete"],"unknownFactIds":["npc-01-moonflower-preference"],"events":[{"kind":"resourceGathered","subjectId":"moonflower","minimumCount":1}]},"entry_index":1,"priority":180,"portraitId":"practiced-smile"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-01-gift-moonflower-from-hint | deferred | {"targetNodeId":"npc-01-gift-response","giftRuleId":"npc-01-moonflower-gift"}; Gift capability unavailable regardless of item ownership; no consume/affinity/cap event. |
| node | npc-01-follow-up-conversation | enabled | {"conditions":{"requiredFlags":["npc-01-first-conversation-complete"]},"entry_index":5,"priority":100,"portraitId":"official-neutral"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-01-gift-moonflower-follow-up | deferred | {"targetNodeId":"npc-01-gift-response","giftRuleId":"npc-01-moonflower-gift"}; Gift capability unavailable regardless of item ownership; no consume/affinity/cap event. |
| node | npc-01-gift-response | deferred | {"entry_index":null,"priority":0,"portraitId":"pleased"}; Only incoming transitions are deferred gift transactions. |
| node | npc-01-level-1-milestone | deferred | {"conditions":{"minimumRelationshipLevel":1,"excludedFlags":["relationshipLevel1Seen"]},"entry_index":0,"priority":300,"portraitId":"practiced-smile"}; Retain level>=1 and unseen milestone gate. Ordinary introduction gives at most1; gifts/progression unavailable. |
| fact | npc-01-public-role | deferred | {"disclosure_nodes":[]}; Declared but no source node discloses this fact; no automatic role/action disclosure. |
| fact | npc-01-moonflower-preference | enabled | {"disclosure_nodes":["npc-01-moonflower-hint"]}; Disclosure only on authored node entry. |
| fact | npc-01-river-fishing | deferred | {"disclosure_nodes":[]}; Declared but no source node discloses this fact; no automatic role/action disclosure. |
| gift_rule | npc-01-moonflower-gift | deferred | {"requiredFactId":"npc-01-moonflower-preference","affinityDelta":1,"acceptanceCap":2}; Typed future gift capability; retain acceptance cap and fact gate without executing. |
| portrait | official-neutral | enabled | {"path":"assets/images/portraits/npc-01/official-neutral.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | practiced-smile | enabled | {"path":"assets/images/portraits/npc-01/practiced-smile.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | skeptical | enabled | {"path":"assets/images/portraits/npc-01/skeptical.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | pleased | enabled | {"path":"assets/images/portraits/npc-01/pleased.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | tired-rumpled | enabled | {"path":"assets/images/portraits/npc-01/tired-rumpled.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | fishing-gear | enabled | {"path":"assets/images/portraits/npc-01/fishing-gear.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| sheet | idle | enabled | {"framesPerFacing":4,"stepSeconds":0.24,"asset":"assets/images/actors/npcs/npc_01_idle_sheet.png","dimensions_px":[768,768]}; ART reference, no 3D asset or runtime animation claim. |
| sheet | walk | enabled | {"framesPerFacing":3,"stepSeconds":0.16,"asset":"assets/images/actors/npcs/npc_01_walk_sheet.png","dimensions_px":[576,768]}; ART reference, no 3D asset or runtime animation claim. |
| sheet | river-fishing | enabled | {"framesPerFacing":4,"stepSeconds":0.2,"asset":"assets/images/actors/npcs/npc_01_river_fishing_sheet.png","dimensions_px":[768,768]}; ART reference, no 3D asset or runtime animation claim. |

## npc-02

| Kind | Stable ID | Status | Gates / disclosure / transition |
| --- | --- | --- | --- |
| node | npc-02-initial-conversation | enabled | {"revealedFactIds":["npc-02-public-role"],"conditions":{"excludedFlags":["npc-02-first-conversation-complete"]},"entry_index":1,"priority":100,"portraitId":"official-neutral"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-02-careful-research-response | enabled | {"targetNodeId":"npc-02-initial-careful-end","affinityDelta":1,"oneTime":true,"oneTimeRewardFlag":"npc-02-careful-reward-applied","addedFlags":["npc-02-first-conversation-complete","npc-02-careful-research-response"]}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-02-neighborly-response | enabled | {"targetNodeId":"npc-02-initial-neighborly-end","affinityDelta":0,"oneTime":true,"oneTimeRewardFlag":"npc-02-neighborly-reward-applied","addedFlags":["npc-02-first-conversation-complete","npc-02-neighborly-response"]}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-02-initial-careful-end | enabled | {"entry_index":null,"priority":0,"portraitId":"pleased"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-02-initial-neighborly-end | enabled | {"entry_index":null,"priority":0,"portraitId":"practiced-smile"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-02-moonflower-hint | enabled | {"revealedFactIds":["npc-02-moonflower-pressing"],"conditions":{"requiredFlags":["npc-02-first-conversation-complete"],"unknownFactIds":["npc-02-moonflower-pressing"],"events":[{"kind":"resourceGathered","subjectId":"moonflower","minimumCount":1}]},"entry_index":0,"priority":180,"portraitId":"pleased"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-02-gift-moonflower-from-hint | deferred | {"targetNodeId":"npc-02-gift-response","giftRuleId":"npc-02-moonflower-gift"}; Gift capability unavailable regardless of item ownership; no consume/affinity/cap event. |
| node | npc-02-follow-up-conversation | enabled | {"conditions":{"requiredFlags":["npc-02-first-conversation-complete"]},"entry_index":2,"priority":100,"portraitId":"official-neutral"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-02-gift-moonflower-follow-up | deferred | {"targetNodeId":"npc-02-gift-response","giftRuleId":"npc-02-moonflower-gift"}; Gift capability unavailable regardless of item ownership; no consume/affinity/cap event. |
| node | npc-02-gift-response | deferred | {"entry_index":null,"priority":0,"portraitId":"pleased"}; Only incoming transitions are deferred gift transactions. |
| node | npc-02-routine-archive-default | deferred | {"revealedFactIds":["npc-02-archive-practice"],"entry_index":4,"priority":10,"portraitId":"tired-rumpled"}; Requires archive routine entry/consumer; no preferred-entry injection, ledger jump or daily suppression. |
| choice | npc-02-resume-archive-default-choice | deferred | {"outcomeTag":"npc-02-resume-archive-default","endsConversation":true}; Requires archive routine entry/consumer; no preferred-entry injection, ledger jump or daily suppression. |
| choice | npc-02-end-archive-default-choice | deferred | {"outcomeTag":"npc-02-end-archive-default","endsConversation":true}; Requires archive routine entry/consumer; no preferred-entry injection, ledger jump or daily suppression. |
| node | npc-02-routine-archive-indexing | deferred | {"entry_index":3,"priority":11,"portraitId":"archive-work"}; Requires archive routine entry/consumer; no preferred-entry injection, ledger jump or daily suppression. |
| choice | npc-02-resume-archive-indexing-choice | deferred | {"outcomeTag":"npc-02-resume-archive-indexing","endsConversation":true}; Requires archive routine entry/consumer; no preferred-entry injection, ledger jump or daily suppression. |
| choice | npc-02-review-archive-ledger-choice | deferred | {"oneTime":true,"addedFlags":["npc-02-archive-lead-shared"],"outcomeTag":"npc-02-review-archive-ledger","endsConversation":true}; Requires archive routine entry/consumer; no preferred-entry injection, ledger jump or daily suppression. |
| choice | npc-02-end-archive-indexing-choice | deferred | {"outcomeTag":"npc-02-end-archive-indexing","endsConversation":true}; Requires archive routine entry/consumer; no preferred-entry injection, ledger jump or daily suppression. |
| fact | npc-02-public-role | enabled | {"disclosure_nodes":["npc-02-initial-conversation"]}; Disclosure only on authored node entry. |
| fact | npc-02-archive-practice | deferred | {"disclosure_nodes":["npc-02-routine-archive-default"]}; Only archive routine discloses this fact. |
| fact | npc-02-moonflower-pressing | enabled | {"disclosure_nodes":["npc-02-moonflower-hint"]}; Disclosure only on authored node entry. |
| gift_rule | npc-02-moonflower-gift | deferred | {"requiredFactId":"npc-02-moonflower-pressing","affinityDelta":1,"acceptanceCap":2}; Typed future gift capability; retain acceptance cap and fact gate without executing. |
| portrait | official-neutral | enabled | {"path":"assets/images/portraits/npc-02/official-neutral.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | practiced-smile | enabled | {"path":"assets/images/portraits/npc-02/practiced-smile.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | skeptical | enabled | {"path":"assets/images/portraits/npc-02/skeptical.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | pleased | enabled | {"path":"assets/images/portraits/npc-02/pleased.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | tired-rumpled | enabled | {"path":"assets/images/portraits/npc-02/tired-rumpled.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | archive-work | enabled | {"path":"assets/images/portraits/npc-02/archive-work.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| sheet | idle | enabled | {"framesPerFacing":4,"stepSeconds":0.24,"asset":"assets/images/actors/npcs/npc_02_idle_sheet.png","dimensions_px":[768,768]}; ART reference, no 3D asset or runtime animation claim. |
| sheet | walk | enabled | {"framesPerFacing":3,"stepSeconds":0.16,"asset":"assets/images/actors/npcs/npc_02_walk_sheet.png","dimensions_px":[576,768]}; ART reference, no 3D asset or runtime animation claim. |
| sheet | archive-work | enabled | {"framesPerFacing":4,"stepSeconds":0.2,"asset":"assets/images/actors/npcs/npc_02_archive_work_sheet.png","dimensions_px":[768,768]}; ART reference, no 3D asset or runtime animation claim. |

## npc-03

| Kind | Stable ID | Status | Gates / disclosure / transition |
| --- | --- | --- | --- |
| node | npc-03-introduction | enabled | {"revealedFactIds":["npc-03-public-role"],"conditions":{"excludedFlags":["npc-03-introduced"]},"entry_index":0,"priority":100,"portraitId":"official-neutral"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-03-careful-response | enabled | {"targetNodeId":"npc-03-careful-end","affinityDelta":1,"oneTime":true,"oneTimeRewardFlag":"npc-03-careful-reward","addedFlags":["npc-03-introduced","npc-03-careful-response"]}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-03-passing-response | enabled | {"targetNodeId":"npc-03-passing-end","affinityDelta":0,"oneTime":true,"oneTimeRewardFlag":"npc-03-passing-reward","addedFlags":["npc-03-introduced","npc-03-passing-response"]}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-03-careful-end | enabled | {"entry_index":null,"priority":0,"portraitId":"pleased"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-03-passing-end | enabled | {"entry_index":null,"priority":0,"portraitId":"practiced-smile"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-03-return | enabled | {"conditions":{"requiredFlags":["npc-03-introduced"]},"entry_index":1,"priority":100,"portraitId":"practiced-smile"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-03-ask-supplies | enabled | {"targetNodeId":"npc-03-supplies"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-03-ask-practice | enabled | {"targetNodeId":"npc-03-practice"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-03-ask-hobby | enabled | {"targetNodeId":"npc-03-hobby"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-03-gift-moonflower | deferred | {"targetNodeId":"npc-03-gift-end","giftRuleId":"npc-03-moonflower-gift"}; Gift capability unavailable regardless of item ownership; no consume/affinity/cap event. |
| node | npc-03-supplies | enabled | {"revealedFactIds":["npc-03-supplier-practice"],"entry_index":null,"priority":0,"portraitId":"official-neutral"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-03-practice | enabled | {"entry_index":null,"priority":0,"portraitId":"skeptical"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-03-hobby | enabled | {"revealedFactIds":["npc-03-decorative-knots"],"entry_index":null,"priority":0,"portraitId":"ropework"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-03-gift-end | deferred | {"entry_index":null,"priority":0,"portraitId":"pleased"}; Only incoming transitions are deferred gift transactions. |
| fact | npc-03-public-role | enabled | {"disclosure_nodes":["npc-03-introduction"]}; Disclosure only on authored node entry. |
| fact | npc-03-supplier-practice | enabled | {"disclosure_nodes":["npc-03-supplies"]}; Disclosure only on authored node entry. |
| fact | npc-03-decorative-knots | enabled | {"disclosure_nodes":["npc-03-hobby"]}; Disclosure only on authored node entry. |
| gift_rule | npc-03-moonflower-gift | deferred | {"requiredFactId":"npc-03-decorative-knots","affinityDelta":1,"acceptanceCap":2}; Typed future gift capability; retain acceptance cap and fact gate without executing. |
| portrait | official-neutral | enabled | {"path":"assets/images/portraits/npc-03/official-neutral.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | practiced-smile | enabled | {"path":"assets/images/portraits/npc-03/practiced-smile.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | skeptical | enabled | {"path":"assets/images/portraits/npc-03/skeptical.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | pleased | enabled | {"path":"assets/images/portraits/npc-03/pleased.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | tired-rumpled | enabled | {"path":"assets/images/portraits/npc-03/tired-rumpled.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | ropework | enabled | {"path":"assets/images/portraits/npc-03/ropework.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| sheet | idle | enabled | {"framesPerFacing":4,"stepSeconds":0.24,"asset":"assets/images/actors/npcs/npc_03_idle_sheet.png","dimensions_px":[768,768]}; ART reference, no 3D asset or runtime animation claim. |
| sheet | walk | enabled | {"framesPerFacing":3,"stepSeconds":0.16,"asset":"assets/images/actors/npcs/npc_03_walk_sheet.png","dimensions_px":[576,768]}; ART reference, no 3D asset or runtime animation claim. |

## npc-04

| Kind | Stable ID | Status | Gates / disclosure / transition |
| --- | --- | --- | --- |
| node | npc-04-introduction | enabled | {"conditions":{"excludedFlags":["npc-04-introduced"]},"revealedFactIds":["npc-04-public-role"],"entry_index":0,"priority":100,"portraitId":"official-neutral"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-04-careful-response | enabled | {"targetNodeId":"npc-04-careful-end","affinityDelta":1,"oneTime":true,"oneTimeRewardFlag":"npc-04-careful-reward","addedFlags":["npc-04-introduced","npc-04-careful-response"]}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-04-passing-response | enabled | {"targetNodeId":"npc-04-passing-end","affinityDelta":0,"oneTime":true,"oneTimeRewardFlag":"npc-04-passing-reward","addedFlags":["npc-04-introduced","npc-04-passing-response"]}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-04-careful-end | enabled | {"entry_index":null,"priority":0,"portraitId":"pleased"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-04-passing-end | enabled | {"entry_index":null,"priority":0,"portraitId":"practiced-smile"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-04-return | enabled | {"conditions":{"requiredFlags":["npc-04-introduced"]},"entry_index":1,"priority":100,"portraitId":"practiced-smile"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-04-ask-work | enabled | {"targetNodeId":"npc-04-work"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-04-ask-weather | enabled | {"targetNodeId":"npc-04-weather"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-04-ask-hobby | enabled | {"targetNodeId":"npc-04-hobby"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-04-gift-moonflower | deferred | {"targetNodeId":"npc-04-gift-end","giftRuleId":"npc-04-moonflower-gift"}; Gift capability unavailable regardless of item ownership; no consume/affinity/cap event. |
| node | npc-04-work | enabled | {"revealedFactIds":["npc-04-shared-checks"],"entry_index":null,"priority":0,"portraitId":"official-neutral"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-04-weather | enabled | {"entry_index":null,"priority":0,"portraitId":"skeptical"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-04-hobby | enabled | {"revealedFactIds":["npc-04-shore-birds"],"entry_index":null,"priority":0,"portraitId":"birdwatching"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-04-gift-end | deferred | {"entry_index":null,"priority":0,"portraitId":"pleased"}; Only incoming transitions are deferred gift transactions. |
| fact | npc-04-public-role | enabled | {"disclosure_nodes":["npc-04-introduction"]}; Disclosure only on authored node entry. |
| fact | npc-04-shared-checks | enabled | {"disclosure_nodes":["npc-04-work"]}; Disclosure only on authored node entry. |
| fact | npc-04-shore-birds | enabled | {"disclosure_nodes":["npc-04-hobby"]}; Disclosure only on authored node entry. |
| gift_rule | npc-04-moonflower-gift | deferred | {"requiredFactId":"npc-04-shore-birds","affinityDelta":1,"acceptanceCap":2}; Typed future gift capability; retain acceptance cap and fact gate without executing. |
| portrait | official-neutral | enabled | {"path":"assets/images/portraits/npc-04/official-neutral.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | practiced-smile | enabled | {"path":"assets/images/portraits/npc-04/practiced-smile.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | skeptical | enabled | {"path":"assets/images/portraits/npc-04/skeptical.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | pleased | enabled | {"path":"assets/images/portraits/npc-04/pleased.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | tired-rumpled | enabled | {"path":"assets/images/portraits/npc-04/tired-rumpled.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | birdwatching | enabled | {"path":"assets/images/portraits/npc-04/birdwatching.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| sheet | idle | enabled | {"framesPerFacing":4,"stepSeconds":0.24,"asset":"assets/images/actors/npcs/npc_04_idle_sheet.png","dimensions_px":[768,768]}; ART reference, no 3D asset or runtime animation claim. |
| sheet | walk | enabled | {"framesPerFacing":3,"stepSeconds":0.16,"asset":"assets/images/actors/npcs/npc_04_walk_sheet.png","dimensions_px":[576,768]}; ART reference, no 3D asset or runtime animation claim. |

## npc-06

| Kind | Stable ID | Status | Gates / disclosure / transition |
| --- | --- | --- | --- |
| node | npc-06-introduction | enabled | {"conditions":{"excludedFlags":["npc-06-introduced"]},"revealedFactIds":["npc-06-public-role"],"entry_index":0,"priority":100,"portraitId":"official-neutral"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-06-careful-response | enabled | {"targetNodeId":"npc-06-careful-end","affinityDelta":1,"oneTime":true,"oneTimeRewardFlag":"npc-06-careful-reward","addedFlags":["npc-06-introduced","npc-06-careful-response"]}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-06-passing-response | enabled | {"targetNodeId":"npc-06-passing-end","affinityDelta":0,"oneTime":true,"oneTimeRewardFlag":"npc-06-passing-reward","addedFlags":["npc-06-introduced","npc-06-passing-response"]}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-06-careful-end | enabled | {"entry_index":null,"priority":0,"portraitId":"pleased"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-06-passing-end | enabled | {"entry_index":null,"priority":0,"portraitId":"practiced-smile"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-06-return | enabled | {"conditions":{"requiredFlags":["npc-06-introduced"]},"entry_index":1,"priority":100,"portraitId":"practiced-smile"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-06-ask-supplies | enabled | {"targetNodeId":"npc-06-supplies"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-06-ask-work | enabled | {"targetNodeId":"npc-06-work"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-06-ask-busy | enabled | {"targetNodeId":"npc-06-busy"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-06-ask-hobby | enabled | {"targetNodeId":"npc-06-hobby"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-06-gift-moonflower | deferred | {"targetNodeId":"npc-06-gift-end","giftRuleId":"npc-06-moonflower-gift"}; Gift capability unavailable regardless of item ownership; no consume/affinity/cap event. |
| node | npc-06-supplies | enabled | {"revealedFactIds":["npc-06-everyday-supplies"],"entry_index":null,"priority":0,"portraitId":"official-neutral"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-06-work | enabled | {"entry_index":null,"priority":0,"portraitId":"skeptical"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-06-busy | enabled | {"entry_index":null,"priority":0,"portraitId":"tired-rumpled"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-06-hobby | enabled | {"revealedFactIds":["npc-06-pressed-flowers"],"entry_index":null,"priority":0,"portraitId":"flower-pressing"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-06-gift-end | deferred | {"entry_index":null,"priority":0,"portraitId":"pleased"}; Only incoming transitions are deferred gift transactions. |
| fact | npc-06-public-role | enabled | {"disclosure_nodes":["npc-06-introduction"]}; Disclosure only on authored node entry. |
| fact | npc-06-everyday-supplies | enabled | {"disclosure_nodes":["npc-06-supplies"]}; Disclosure only on authored node entry. |
| fact | npc-06-pressed-flowers | enabled | {"disclosure_nodes":["npc-06-hobby"]}; Disclosure only on authored node entry. |
| gift_rule | npc-06-moonflower-gift | deferred | {"requiredFactId":"npc-06-pressed-flowers","affinityDelta":1,"acceptanceCap":2}; Typed future gift capability; retain acceptance cap and fact gate without executing. |
| portrait | official-neutral | enabled | {"path":"assets/images/portraits/npc-06/official-neutral.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | practiced-smile | enabled | {"path":"assets/images/portraits/npc-06/practiced-smile.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | skeptical | enabled | {"path":"assets/images/portraits/npc-06/skeptical.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | pleased | enabled | {"path":"assets/images/portraits/npc-06/pleased.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | tired-rumpled | enabled | {"path":"assets/images/portraits/npc-06/tired-rumpled.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | flower-pressing | enabled | {"path":"assets/images/portraits/npc-06/flower-pressing.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| sheet | idle | enabled | {"framesPerFacing":4,"stepSeconds":0.24,"asset":"assets/images/actors/npcs/npc_06_idle_sheet.png","dimensions_px":[768,768]}; ART reference, no 3D asset or runtime animation claim. |
| sheet | walk | enabled | {"framesPerFacing":3,"stepSeconds":0.16,"asset":"assets/images/actors/npcs/npc_06_walk_sheet.png","dimensions_px":[576,768]}; ART reference, no 3D asset or runtime animation claim. |

## npc-07

| Kind | Stable ID | Status | Gates / disclosure / transition |
| --- | --- | --- | --- |
| node | npc-07-introduction | enabled | {"conditions":{"excludedFlags":["npc-07-introduced"]},"revealedFactIds":["npc-07-public-role"],"entry_index":0,"priority":100,"portraitId":"official-neutral"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-07-careful-response | enabled | {"targetNodeId":"npc-07-careful-end","affinityDelta":1,"oneTime":true,"oneTimeRewardFlag":"npc-07-careful-reward","addedFlags":["npc-07-introduced","npc-07-careful-response"]}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-07-passing-response | enabled | {"targetNodeId":"npc-07-passing-end","affinityDelta":0,"oneTime":true,"oneTimeRewardFlag":"npc-07-passing-reward","addedFlags":["npc-07-introduced","npc-07-passing-response"]}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-07-careful-end | enabled | {"entry_index":null,"priority":0,"portraitId":"pleased"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-07-passing-end | enabled | {"entry_index":null,"priority":0,"portraitId":"practiced-smile"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-07-return | enabled | {"conditions":{"requiredFlags":["npc-07-introduced"]},"entry_index":1,"priority":100,"portraitId":"practiced-smile"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-07-ask-supplies | enabled | {"targetNodeId":"npc-07-supplies"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-07-ask-work | enabled | {"targetNodeId":"npc-07-work"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-07-ask-busy | enabled | {"targetNodeId":"npc-07-busy"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-07-ask-hobby | enabled | {"targetNodeId":"npc-07-hobby"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-07-gift-moonflower | deferred | {"targetNodeId":"npc-07-gift-end","giftRuleId":"npc-07-moonflower-gift"}; Gift capability unavailable regardless of item ownership; no consume/affinity/cap event. |
| node | npc-07-supplies | enabled | {"revealedFactIds":["npc-07-local-seamanship"],"entry_index":null,"priority":0,"portraitId":"official-neutral"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-07-work | enabled | {"entry_index":null,"priority":0,"portraitId":"skeptical"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-07-busy | enabled | {"entry_index":null,"priority":0,"portraitId":"tired-rumpled"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-07-hobby | enabled | {"revealedFactIds":["npc-07-knotwork"],"entry_index":null,"priority":0,"portraitId":"knotwork"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-07-gift-end | deferred | {"entry_index":null,"priority":0,"portraitId":"pleased"}; Only incoming transitions are deferred gift transactions. |
| fact | npc-07-public-role | enabled | {"disclosure_nodes":["npc-07-introduction"]}; Disclosure only on authored node entry. |
| fact | npc-07-local-seamanship | enabled | {"disclosure_nodes":["npc-07-supplies"]}; Disclosure only on authored node entry. |
| fact | npc-07-knotwork | enabled | {"disclosure_nodes":["npc-07-hobby"]}; Disclosure only on authored node entry. |
| gift_rule | npc-07-moonflower-gift | deferred | {"requiredFactId":"npc-07-knotwork","affinityDelta":1,"acceptanceCap":2}; Typed future gift capability; retain acceptance cap and fact gate without executing. |
| portrait | official-neutral | enabled | {"path":"assets/images/portraits/npc-07/official-neutral.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | practiced-smile | enabled | {"path":"assets/images/portraits/npc-07/practiced-smile.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | skeptical | enabled | {"path":"assets/images/portraits/npc-07/skeptical.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | pleased | enabled | {"path":"assets/images/portraits/npc-07/pleased.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | tired-rumpled | enabled | {"path":"assets/images/portraits/npc-07/tired-rumpled.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | knotwork | enabled | {"path":"assets/images/portraits/npc-07/knotwork.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| sheet | idle | enabled | {"framesPerFacing":4,"stepSeconds":0.24,"asset":"assets/images/actors/npcs/npc_07_idle_sheet.png","dimensions_px":[768,768]}; ART reference, no 3D asset or runtime animation claim. |
| sheet | walk | enabled | {"framesPerFacing":3,"stepSeconds":0.16,"asset":"assets/images/actors/npcs/npc_07_walk_sheet.png","dimensions_px":[576,768]}; ART reference, no 3D asset or runtime animation claim. |

## npc-08

| Kind | Stable ID | Status | Gates / disclosure / transition |
| --- | --- | --- | --- |
| node | npc-08-introduction | enabled | {"conditions":{"excludedFlags":["npc-08-introduced"]},"revealedFactIds":["npc-08-public-role"],"entry_index":0,"priority":100,"portraitId":"official-neutral"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-08-careful-response | enabled | {"targetNodeId":"npc-08-careful-end","affinityDelta":1,"oneTime":true,"oneTimeRewardFlag":"npc-08-careful-reward","addedFlags":["npc-08-introduced","npc-08-careful-response"]}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-08-passing-response | enabled | {"targetNodeId":"npc-08-passing-end","affinityDelta":0,"oneTime":true,"oneTimeRewardFlag":"npc-08-passing-reward","addedFlags":["npc-08-introduced","npc-08-passing-response"]}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-08-careful-end | enabled | {"entry_index":null,"priority":0,"portraitId":"pleased"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-08-passing-end | enabled | {"entry_index":null,"priority":0,"portraitId":"practiced-smile"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-08-return | enabled | {"conditions":{"requiredFlags":["npc-08-introduced"]},"entry_index":1,"priority":100,"portraitId":"practiced-smile"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-08-ask-supplies | enabled | {"targetNodeId":"npc-08-supplies"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-08-ask-demo | enabled | {"targetNodeId":"npc-08-demo"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-08-ask-busy | enabled | {"targetNodeId":"npc-08-busy"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-08-ask-hobby | enabled | {"targetNodeId":"npc-08-hobby"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-08-gift-moonflower | deferred | {"targetNodeId":"npc-08-gift-end","giftRuleId":"npc-08-moonflower-gift"}; Gift capability unavailable regardless of item ownership; no consume/affinity/cap event. |
| node | npc-08-supplies | enabled | {"revealedFactIds":["npc-08-basic-repairs"],"entry_index":null,"priority":0,"portraitId":"official-neutral"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-08-demo | enabled | {"entry_index":null,"priority":0,"portraitId":"skeptical"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-08-busy | enabled | {"entry_index":null,"priority":0,"portraitId":"tired-rumpled"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-08-hobby | enabled | {"revealedFactIds":["npc-08-woodcarving"],"entry_index":null,"priority":0,"portraitId":"woodcarving"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-08-gift-end | deferred | {"entry_index":null,"priority":0,"portraitId":"pleased"}; Only incoming transitions are deferred gift transactions. |
| fact | npc-08-public-role | enabled | {"disclosure_nodes":["npc-08-introduction"]}; Disclosure only on authored node entry. |
| fact | npc-08-basic-repairs | enabled | {"disclosure_nodes":["npc-08-supplies"]}; Disclosure only on authored node entry. |
| fact | npc-08-woodcarving | enabled | {"disclosure_nodes":["npc-08-hobby"]}; Disclosure only on authored node entry. |
| gift_rule | npc-08-moonflower-gift | deferred | {"requiredFactId":"npc-08-woodcarving","affinityDelta":1,"acceptanceCap":2}; Typed future gift capability; retain acceptance cap and fact gate without executing. |
| portrait | official-neutral | enabled | {"path":"assets/images/portraits/npc-08/official-neutral.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | practiced-smile | enabled | {"path":"assets/images/portraits/npc-08/practiced-smile.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | skeptical | enabled | {"path":"assets/images/portraits/npc-08/skeptical.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | pleased | enabled | {"path":"assets/images/portraits/npc-08/pleased.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | tired-rumpled | enabled | {"path":"assets/images/portraits/npc-08/tired-rumpled.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | woodcarving | enabled | {"path":"assets/images/portraits/npc-08/woodcarving.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| sheet | idle | enabled | {"framesPerFacing":4,"stepSeconds":0.24,"asset":"assets/images/actors/npcs/npc_08_idle_sheet.png","dimensions_px":[768,768]}; ART reference, no 3D asset or runtime animation claim. |
| sheet | walk | enabled | {"framesPerFacing":3,"stepSeconds":0.16,"asset":"assets/images/actors/npcs/npc_08_walk_sheet.png","dimensions_px":[576,768]}; ART reference, no 3D asset or runtime animation claim. |

## npc-14

| Kind | Stable ID | Status | Gates / disclosure / transition |
| --- | --- | --- | --- |
| node | npc-14-introduction | enabled | {"conditions":{"excludedFlags":["npc-14-introduced"]},"revealedFactIds":["npc-14-public-role"],"entry_index":0,"priority":100,"portraitId":"official-neutral"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-14-careful-response | enabled | {"targetNodeId":"npc-14-careful-end","affinityDelta":1,"oneTime":true,"oneTimeRewardFlag":"npc-14-careful-reward","addedFlags":["npc-14-introduced","npc-14-careful-response"]}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-14-passing-response | enabled | {"targetNodeId":"npc-14-passing-end","affinityDelta":0,"oneTime":true,"oneTimeRewardFlag":"npc-14-passing-reward","addedFlags":["npc-14-introduced","npc-14-passing-response"]}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-14-careful-end | enabled | {"entry_index":null,"priority":0,"portraitId":"pleased"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-14-passing-end | enabled | {"entry_index":null,"priority":0,"portraitId":"practiced-smile"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-14-return | enabled | {"conditions":{"requiredFlags":["npc-14-introduced"]},"entry_index":1,"priority":100,"portraitId":"practiced-smile"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-14-ask-hosting | enabled | {"targetNodeId":"npc-14-hosting"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-14-ask-quiet | enabled | {"targetNodeId":"npc-14-quiet"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-14-ask-room | deferred | {"targetNodeId":"npc-14-room"}; Interior directional branch unavailable at exterior contact; no room entitlement or guessed indoor transform. |
| choice | npc-14-ask-busy | enabled | {"targetNodeId":"npc-14-busy"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-14-ask-hobby | enabled | {"targetNodeId":"npc-14-hobby"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| choice | npc-14-gift-moonflower | deferred | {"targetNodeId":"npc-14-gift-end","giftRuleId":"npc-14-moonflower-gift"}; Gift capability unavailable regardless of item ownership; no consume/affinity/cap event. |
| node | npc-14-hosting | enabled | {"entry_index":null,"priority":0,"portraitId":"official-neutral"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-14-quiet | enabled | {"revealedFactIds":["npc-14-quiet-company"],"entry_index":null,"priority":0,"portraitId":"skeptical"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-14-room | deferred | {"entry_index":null,"priority":0,"portraitId":"official-neutral"}; Interior directional branch unavailable at exterior contact; no room entitlement or guessed indoor transform. |
| node | npc-14-busy | enabled | {"entry_index":null,"priority":0,"portraitId":"tired-rumpled"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-14-hobby | enabled | {"revealedFactIds":["npc-14-quilting"],"entry_index":null,"priority":0,"portraitId":"quilting"}; Ordinary public graph; preserve all authored gates and text except explicit audited adaptation. |
| node | npc-14-gift-end | deferred | {"entry_index":null,"priority":0,"portraitId":"pleased"}; Only incoming transitions are deferred gift transactions. |
| fact | npc-14-public-role | enabled | {"disclosure_nodes":["npc-14-introduction"]}; Disclosure only on authored node entry. |
| fact | npc-14-quiet-company | enabled | {"disclosure_nodes":["npc-14-quiet"]}; Disclosure only on authored node entry. |
| fact | npc-14-quilting | enabled | {"disclosure_nodes":["npc-14-hobby"]}; Disclosure only on authored node entry. |
| gift_rule | npc-14-moonflower-gift | deferred | {"requiredFactId":"npc-14-quilting","affinityDelta":1,"acceptanceCap":2}; Typed future gift capability; retain acceptance cap and fact gate without executing. |
| portrait | official-neutral | enabled | {"path":"assets/images/portraits/npc-14/official-neutral.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | practiced-smile | enabled | {"path":"assets/images/portraits/npc-14/practiced-smile.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | skeptical | enabled | {"path":"assets/images/portraits/npc-14/skeptical.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | pleased | enabled | {"path":"assets/images/portraits/npc-14/pleased.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | tired-rumpled | enabled | {"path":"assets/images/portraits/npc-14/tired-rumpled.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| portrait | quilting | enabled | {"path":"assets/images/portraits/npc-14/quilting.png","dimensions_px":[512,512]}; Exact reference pixels; expressions stay available, disclosure remains graph-gated. |
| sheet | idle | enabled | {"framesPerFacing":4,"stepSeconds":0.24,"asset":"assets/images/actors/npcs/npc_14_idle_sheet.png","dimensions_px":[768,768]}; ART reference, no 3D asset or runtime animation claim. |
| sheet | walk | enabled | {"framesPerFacing":3,"stepSeconds":0.16,"asset":"assets/images/actors/npcs/npc_14_walk_sheet.png","dimensions_px":[576,768]}; ART reference, no 3D asset or runtime animation claim. |
