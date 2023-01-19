
walker ingest_faq {
    has kb_file;

    root: take -[conv_root]-> node::conv_root;
    conv_root: take -[dialogue_root]-> node::dialogue_root;
    dialogue_root: take -[intent_transition]-> node::faq_root;
    faq_root {
        kb = file.load_json(global.train_faq_answer_path);
        for faq in kb {
            answer = faq["answer"];
            std.out(answer);
            spawn here +[faq]+> node::faq_state(name = "faq_state", answer=answer);

        }
    }
}

walker maintainer {
    has prev_state;
    // has skip_state;
    has dialogue_context;
    root: take -[conv_root]-> node::conv_root;
    conv_root: take -[user]-> node::user;
}

walker create_node_and_edge{
    has first_node = "";
    has second_node = "";
    has template = "";          // response_only
    has intent = "";            // greetings
    has entities = [];          // number
    has name = "";              // number


    with entry {
        if(first_node == ""): first_node = global.dialogue_root;
        bienc = file.load_json(global.train_classifer_path);


        
        if(second_node ==""){
            // std.out("first_node");
            // std.out(first_node);
            uuid_1 = spawn *(first_node) walker::get_jac_uuid;
            std.out("First");

            if(template == "response_only"){
                uuid_2 = spawn node::response_only_template(imprint=[{"list_imprint": bienc[intent], "name": intent}], name=intent);
            }
            elif(template == "extract_info"){
                if (intent in bienc){
                    uuid_2 = spawn node::extract_info_template(imprint=[{"list_imprint": bienc[intent], "name": intent}], name=intent);
                }
                else{
                    uuid_2 = spawn node::extract_info_template(name=intent);
                    global.entity_label.list::append(intent);
                }
            }
            elif(template == "collect_info"){
                if (intent in bienc){
                    uuid_2 = spawn node::collect_info_template(imprint=[{"list_imprint": bienc[intent], "name": intent}], name=intent);
                }
                else{
                    uuid_2 = spawn node::collect_info_template(name=intent);
                    global.entity_label.list::append(intent);
                }
            }

            if(intent != ""){
                uuid_1 +[intent_transition(intent=intent.str)]+> uuid_2;
            }
            elif(entities.length > 0){
                uuid_1 +[entity_transition(entities=entities)]+>uuid_2;
            }
            elif(name != ""){
                uuid_1 +[redirect_transition(name=name)]+>uuid_2;
            }

            report:custom = {"uuid_1":uuid_1.info['jid'], "uuid_2":uuid_2.info['jid']};
        }
        elif (second_node !=""){
            uuid_1 = spawn *(first_node) walker::get_jac_uuid;
            uuid_2 = spawn *(second_node) walker::get_jac_uuid;
            std.out("Second");

            if(intent != ""){
                uuid_1 +[intent_transition(intent=intent.str)]+> uuid_2;
            }
            elif(entities.length > 0){
                uuid_1 +[entity_transition(entities=entities)]+>uuid_2;
            }
            elif(name != ""){
                uuid_1 +[redirect_transition(name=name)]+>uuid_2;
            }
            report:custom = {"uuid_1":uuid_1.info['jid'], "uuid_2":uuid_2.info['jid']};
        }
    }
}

walker get_jac_uuid{
    has anchor uuid;
    with entry{
        uuid = here;
        // report:custom = uuid;
    }
}


walker talk {
    has question, phone_number;
    has predicted_intent;
    has extracted_entities={};
    has dialogue_context ={};
    // has skip_state = null;
    has response;
    has next_state;
    has prev_state;
    has cont_state;
    has respond = true;
    // has media = "";
    has threshold = false;

    root: take -[conv_root]-> node::conv_root;
    conv_root {
        take -[user]-> node::user;
    }
    user {
        if(cont_state == ""): std.out('WALKER TALKER ERROR: cont_state is an EMPTY STR');
        take *(cont_state);
    }
    dialogue_state {
        if (respond) {
            take next_state else {
                report {
                    "name": here.name,
                    "response": "Sorry I can't handle that just yet."
                };
            }
            respond = false;
        } 
    }
}
