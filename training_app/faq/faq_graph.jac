node faq_root_t;
node faq_state_t{
    has question;
    has answer;
}

edge faq_root_t;
edge faq_state_t: has id;