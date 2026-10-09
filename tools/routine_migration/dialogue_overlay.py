"""R011 narrow public routine activation, composed AFTER existing social overlay."""
import copy

def apply(packages):
    result = copy.deepcopy(packages)
    helena = next(p for p in result if p['id'] == 'npc-02')
    enabled = {'node': ['npc-02-routine-archive-default', 'npc-02-routine-archive-indexing'],
               'choice': ['npc-02-resume-archive-default-choice', 'npc-02-end-archive-default-choice',
                          'npc-02-resume-archive-indexing-choice', 'npc-02-review-archive-ledger-choice',
                          'npc-02-end-archive-indexing-choice'], 'fact': ['npc-02-archive-practice']}
    for kind, ids in enabled.items():
        for identity in ids:
            assert identity in helena['coverage'][kind]
            helena['coverage'][kind][identity] = {'status':'enabled', 'reason':'R011 public archive dialogue; live routine lease gates entry/directives, authored node entry alone discloses fact.'}
    # R008 current indoor public wording; retain that accepted adaptation when
    # composing immutable N001 + G004 pins. No room entitlement/sleep activation.
    della = next(p for p in result if p['id'] == 'npc-14')
    indoor_text = {'npc-14-introduction': 'Della Pike, **innkeeper** at Lantern Rest. Questions and quiet company are welcome here in the meal room. Paid rooms, booking and sleep are unavailable in this prototype.', 'npc-14-return': 'What would you like to know?'}
    for node in della['dialogue']['nodes']:
        if node['id'] in indoor_text: node['text'] = indoor_text[node['id']]
    for kind,identity in [('node','npc-14-room'),('choice','npc-14-ask-room')]:
        della['coverage'][kind][identity]['reason']='Paid lodging directions remain deferred; public meal-room access grants no room entitlement or sleep.'
    return result
