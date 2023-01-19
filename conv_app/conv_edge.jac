
edge conv_root;
edge dialogue_root;
edge user;


edge intent_transition {
    has intent;
}

edge redirect_transition {
    has name;
}

edge entity_transition {
    has entities;
}

edge faq_root;
edge faq;
