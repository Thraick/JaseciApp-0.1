
# name, imprint
# return to d

node response_only_template:dialogue_state{
    has name;

    can nlu with talk entry {
        state_json = file.load_json(global.train_state_path);
        for state in state_json{
            if (!visitor.respond) {
                if (here.name == state["name"].str){
                    arry = flow.select_response(null, state['responses'], null);
                    // std.out(arry);
                    visitor.response = arry[1];
                }
            }
        }
    }

    can process with talk entry{
        visitor.next_state = -[intent_transition(intent==global.dialogue_root)]->;
    }
}

node extract_info_template:dialogue_state{
    // has name = "number";
    has name;

    can nlu with talk entry {
        // std.out(" in number \n\n");
        ::classify_intent;
        ::extract_entities;
        ::business_logic;

        state_json = file.load_json(global.train_state_path);
        for state in state_json{
            if (!visitor.respond) {
                if (here.name == state["name"].str){
                    arry = flow.select_response(state["extracted_item"], state["responses"], visitor.dialogue_context); # select a response
                    if(arry[0] != ""){
                        visitor.response = arry[1];
                        visitor.next_state = here;
                    }
                    elif(arry[0] == ""){
                        my_dict = flow.info_json(state['resource'], visitor.dialogue_context, state['variable'] ); # setup data for response
                        visitor.dialogue_context = my_dict;
                        ans = flow.gen_response(arry[1], my_dict, null);
                        visitor.response = ans;
                    }
                }
            }
        }
    }
}


node collect_info_template:dialogue_state{
    // has name = "account";
    has name;

    can nlu with talk entry{
        ::classify_intent;
        ::extract_entities;
        ::business_logic;
        
        state_json = file.load_json(global.train_state_path);
        for state in state_json{
            if (!visitor.respond) {
                if (here.name == state["name"].str){
                    if (state["variable"][0] not in visitor.dialogue_context){
                        // visitor.next_state = -[intent_transition(intent=="number")]->[0];
                        visitor.next_state = -[redirect_transition(name=="number")]->[0];
                        visitor.respond = true;
                        visitor.predicted_intent = '';
                        // std.out('in if info account');

                    }
                    else{
                        arry = flow.select_response(null, state['responses'], null);
                        visitor.response = arry[1];

                        my_dict = flow.info_json(state['resource'], visitor.dialogue_context, state['variable'] ); # setup data for response
                        visitor.dialogue_context = my_dict;
                        // std.out(visitor.dialogue_context);
                        ans = flow.gen_response(arry[1], my_dict['info_json'][0], null);
                        visitor.response = ans;
                    }
                }
            }
        }
    }

    can process with talk entry{
        // if(visitor.next_state){
        //     std.out('go to number');
        // }
        if(!visitor.next_state){
            // std.out('in if not account');
            // visitor.next_state = -[intent_transition(intent==global.dialogue_root)]->[0];
            // visitor.next_state = -[intent_transition(intent=="dialogue_root")]->[0];
            // std.out(global.dialogue_root);
            // std.out(visitor.next_state);
            // visitor.next_state = global.dialogue_root;

        }
    }
}



node dialogue_state{
    has imprint;

    // hold threshold list
    // ai kit 
    can bi_enc.infer;
    can tfm_ner.extract_entity;
    can use.text_classify;

    // custom modules
    can flow.info_json;
    can flow.select_response;
    can flow.gen_response;
    can flow.collect_info;
    can flow.select_options;
    can twilio.twilio_bot;

    can classify_intent {
        if(visitor.respond){

            imprints = -->.imprint;
            intent_labels = -[intent_transition]->.edge.intent;
            std.out("intent_labels");
            std.out(intent_labels);
            max_score = global.conv_score;
            intent = "";

            for imprint in imprints {
                std.out("imprint");
                std.out(imprint[0]);
                if (imprint[0].type == dict ){

                    best_answer = use.text_classify(
                        text = visitor.question,
                        classes = imprint[0].list_imprint.list
                    );
                    nn = best_answer['match_idx'];
                    if (best_answer['scores'][nn] > max_score){
                        max_score = best_answer['scores'][nn];
                        intent = imprint[0].name;
                    }
                    std.out(best_answer['scores'][nn]);
                    std.out(imprint[0].name);
                }
            }
            
            if (max_score > global.conv_score and intent in intent_labels){
                visitor.threshold = true;
                visitor.predicted_intent = intent;
            }
            std.log("THRESHOLD: ", global.conv_score,"   SCORE: " , max_score);
            std.log("INTENT:  ", visitor.predicted_intent);
            // std.out("intent");
        }
    }

    // can check_threshold with talk entry{
    //     if(visitor.respond){

    //         imprints = -->.imprint;
    //         max_score = global.conv_score;
    //         intent = "";

    //         for imprint in imprints {
    //             if (imprint.type == dict ){

    //                 best_answer = use.text_classify(
    //                     text = visitor.question,
    //                     classes = imprint.list_imprint.list
    //                 );
    //                 std.out(best_answer);
    //                 nn = best_answer['match_idx'];
    //                 if (best_answer['scores'][nn] > max_score){
    //                     max_score = best_answer['scores'][nn];
    //                     intent = imprint.name;
    //                 }
    //             }
    //         }
    //         if (max_score > global.conv_score){
    //             visitor.threshold = true;
    //             visitor.predicted_intent = intent
    //         }
    //         std.log("THRESHOLD: ", global.conv_score,"   SCORE: " , max_score);
    //         // std.out("intent");
    //         // std.out(intent);
    //     }
    // }

    // can classify_intent {
    //     if(visitor.respond){
    //         intent_labels = -[intent_transition]->.edge.intent;
    //         // std.out(here.name);
    //         // std.out(intent_labels);
    //         predicted = bi_enc.infer(
    //             contexts = [visitor.question],
    //             candidates = intent_labels,
    //             context_type = "text",
    //             candidate_type = "text"
    //         );
    //         if (predicted[0]['predicted']['score'] > global.conv_score){
    //             // visitor.predicted_intent = predicted[0]["predicted"]["label"];
    //         }
    //         // std.out("predicted\n");
    //         std.log("INTENT:  ", visitor.predicted_intent);
    //     }
    // }

    can extract_entities {
        if(visitor.respond){
            res = tfm_ner.extract_entity(visitor.question);
            if(res.type == list || res.type == dict){

                for ent in res {
                    ent_type = ent["entity_value"];
                    ent_text = ent["entity_text"];
                    if ( !(ent_type in visitor.extracted_entities) ){
                        visitor.extracted_entities[ent_type] = [];
                    }
                    
                    if( ent_text not in visitor.extracted_entities[ent_type] ){
                        visitor.extracted_entities[ent_type].l::append(ent_text);
                    }
                }
            }
            std.log("ENTITIES:  ", visitor.extracted_entities);
        }
    }

    can business_logic {
        visitor.dialogue_context.dict::update(visitor.extracted_entities);
        std.out("global.entity_label");
        std.out(global.entity_label);
        for label in global.entity_label {
            if (label in visitor.extracted_entities) {
                visitor.dialogue_context[label]=visitor.extracted_entities[label];
            }
        }
    }

    can nlu with talk entry {}

    can process with talk entry {

        required_entities = -[entity_transition]->.edge.entities;

        if(visitor.extracted_entities){
            for i in required_entities{
                if (i == visitor.extracted_entities.d::keys){
                    visitor.next_state = -[entity_transition(entities==visitor.extracted_entities.d::keys)]->[0];
                }
            }
        }
        elif(visitor.predicted_intent and visitor.threshold){
            // std.out(intent[0]['name']);
            // visitor.next_state = -[intent_transition(intent[0]['name'] == visitor.predicted_intent)]->[0];
            visitor.next_state = -[intent_transition(intent == visitor.predicted_intent)]->[0];
        }
        else{
            visitor.next_state = null;
        }
    }

    can nlg with talk entry {
        if (!visitor.respond) {
        // if (!visitor.respond and here.name != "dialogue_root") {
            report {
                "question": visitor.question,
                "name": here.name,
                "response": visitor.response
            };
            // twilio.twilio_bot(visitor.response, visitor.phone_number);
        }
    }

    can cleanup with talk entry {
        intent_labels = -[intent_transition]->.edge.intent;
        if(intent_labels.length == 0){
            visitor.prev_state = global.dialogue_root;
        }
        else{
            visitor.prev_state = here.info['jid'];
        }
        // std.out("visitor.prev_state\n\n");
        // std.out(visitor.prev_state);
        // std.out(here.name);

        spawn *(global.main_root) walker::maintainer( 
            prev_state = visitor.prev_state,
            // skip_state = visitor.skip_state,
            dialogue_context = visitor.dialogue_context
        );
    }
}

node dialogue_root:dialogue_state{
    has name="dialogue_root";

    can nlu with talk entry{
        ::classify_intent;
        ::extract_entities;
        ::business_logic;

        visitor.response = "this is the dialogue root";
    }

    // can process with talk entry{
    //     if
    // }
    // can nlg with talk entry{
    //     if (!visitor.respond) {
    //     // if (!visitor.respond and here.name != "dialogue_root") {
    //         report {
    //             "question": visitor.question,
    //             "name": here.name,
    //             "response": visitor.response
    //         };
    //         // twilio.twilio_bot(visitor.response, visitor.phone_number);
    //     }
    // }


}

node soc:dialogue_state{
    has name = "greetings";

    can nlu with talk entry {
        state_json = file.load_json(global.train_state_path);
        for state in state_json{
            if (!visitor.respond) {
                if (here.name == state["name"].str){
                    arry = flow.select_response(null, state['responses'], null);
                    // std.out(arry);
                    visitor.response = arry[1];
                }
            }
        }
    }

    can process with talk entry{
        visitor.next_state = -[intent_transition(intent==global.dialogue_root)]->;
    }

}

node eoc:dialogue_state{
    has name = "goodbye";

    can nlu with talk entry {
        state_json = file.load_json(global.train_state_path);
        for state in state_json{
            if (!visitor.respond) {
                if (here.name == state["name"].str){
                    arry = flow.select_response(null, state['responses'], null);
                    // std.out(arry);
                    visitor.response = arry[1];
                }
            }
        }
    }

    can process with talk entry{
        visitor.next_state = -[intent_transition(intent==global.dialogue_root)]->;
    }
}

node faq_root:dialogue_state{
    has name;
    has classifier;

    can use.qa_classify;

    can nlu with talk entry{
        answers = -->.answer;
        best_answer = use.qa_classify(
            text = visitor.question,
            classes = answers
        );
        max_score = global.faq_score;
        nn = best_answer['match_idx'];
        std.log( "FAQ: " + " MATCH: ",best_answer['match'],"   SCORE: " ,best_answer['scores'][nn]);

        if (best_answer['scores'][nn] > max_score){
            visitor.response = best_answer['match'];
        }
    }

    can process with talk entry{
        if(visitor.prev_state){
            // std.out('fr process if 1');
            visitor.next_state = *(visitor.prev_state);
            // std.out("check with previous state visitor.next_state\n");
            // std.out(visitor.next_state);
            // visitor.next_state= -[intent_transition(intent==visitor.prev_state)]->;
        }
        else{ 
            // std.out('fr process if 2');
            visitor.next_state = global.dialogue_root;
        }
    }
    can cleanup with talk entry{

    }

}

node faq_state{
    has name;
    has answer;
}

node conv_root;

node user {
    has id;
    has prev_state = null;
    // has skip_state = null;
    has dialogue_context ={};

    can start_conv with talk entry {
        if (here.prev_state == null) {
            here.prev_state = global.dialogue_root;
        }
        visitor.cont_state = here.prev_state;
        visitor.dialogue_context = here.dialogue_context;
        // visitor.skip_state = here.skip_state;
    }

    can update_with_conv with maintainer entry {
        here.prev_state = visitor.prev_state;
        // here.skip_state = visitor.skip_state;
        here.dialogue_context = visitor.dialogue_context;
    }
}

/*


response
extract info
collect info

*/