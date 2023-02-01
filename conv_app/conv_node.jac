
node response_only_template:dialogue_state{
    has name;

    can nlu with talk entry {
        ::classify_intent;
        ::extract_entities;
        ::business_logic;

        state_json = file.load_json(global.train_state_path);
        for state in state_json{
            if (!visitor.respond) {
                if (here.name == state["name"].str){
                    arry = flow.select_response({}, state['responses'], {});
                    // arry = flow.select_response(null, state['responses'], null);
                    // std.out(arry);
                    visitor.response = arry['response'];
                    // visitor.response = arry[1];
                }
            }
        }
    }

    // can process with talk entry{
    //     visitor.next_state = -[intent_transition(intent==global.dialog)]->;
    // }
}
// respond only 
// redirect to dialog

node extract_info_template:dialogue_state{
    has name;

    can nlu with talk entry {
        ::classify_intent;
        ::extract_entities;
        ::business_logic;

        state_json = file.load_json(global.train_state_path);
        for state in state_json{
            if (here.name == state["name"].str){
                arry = flow.select_response(state["extracted_item"], state["responses"], visitor.dialogue_context); # select a response
                if(arry["name"] != ""){
                    visitor.response = arry['response'];
                    visitor.next_state = here;
                }
                elif(arry['name'] == ""){
                    my_dict = flow.info_json(state['resource'], visitor.dialogue_context, state['variable'] ); # setup data for response

                    if(my_dict['info_json'].length != 0){
                        visitor.extracted_entities = my_dict['info_json'][0];
                        ::business_logic;
                    }
                    else{
                        ans = flow.gen_response(arry['response'], my_dict, null);
                        visitor.response = ans;
                    }
                }
            }
        }
    }
}
// confirm entity
// if entity found: redirect to collect_info_template
// faq intent_transition

node collect_info_template:dialogue_state{
    has name;

    can nlu with talk entry{
        ::extract_entities;
        ::business_logic;
        
        state_json = file.load_json(global.train_state_path);
        for state in state_json{
            if (!visitor.respond) {
                if (here.name == state["name"].str){
                    if (state["variable"][0] not in visitor.dialogue_context){
                        visitor.next_state = -[redirect_transition]->[0];
                        visitor.respond = true;
                        visitor.predicted_intent = '';
                    }
                    else{
                        arry = flow.select_response({}, state['responses'], {});
                        ans = flow.gen_response(arry['response'], visitor.dialogue_context, null);
                        visitor.response = ans;
                        visitor.next_state = -[intent_transition(intent==global.dialog)]->;
                    }
                }
            }
        }
    }
}
// if entity not found: redirect to extract_info_template





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
    can flow.check_required_entity;

    can classify_intent {
        if(visitor.respond){

            imprints = -[intent_transition]->.imprint;
            intent_labels = -[intent_transition]->.edge.intent;
            std.out("intent_labels");
            std.out(intent_labels);
            max_score = global.conv_score;
            intent = "";

            for imprint in imprints {
                // std.out("imprint dict");
                // std.out(imprint[0]);
                // std.out(imprint[0]['list_imprint']);
                if (imprint[0].type == dict ){

                    best_answer = use.text_classify(
                        text = visitor.question,
                        classes = imprint[0]['list_imprint'].list
                    );
                    // std.out("best_answer");
                    // std.out(best_answer);
                    nn = best_answer['match_idx'];
                    if (best_answer['scores'][nn] > max_score){
                        max_score = best_answer['scores'][nn];
                        intent = imprint[0].name;
                    }
                    // std.out('here.name\n');
                    // std.out(here.name);
                    // std.out(best_answer['scores'][nn]);
                    // std.out(imprint[0].name);
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
        // std.out("global.entity_label");
        // std.out(global.entity_label);
        for label in global.entity_label {
            if (label in visitor.extracted_entities) {
                visitor.dialogue_context[label]=visitor.extracted_entities[label][0];
            }
        }
    }

    can nlu with talk entry {}

    can process with talk entry {
        if(visitor.respond){

            required_entities = -[entity_transition]->.edge.entities;
            redirect = -[redirect_transition]->;
            // std.out("redirect 1");
            // std.out(redirect);
            // std.out("visitor.respond");
            // std.out(visitor.respond);

            if(visitor.extracted_entities and !visitor.next_state){
                if(required_entities){
                    for entity in required_entities{
                        required = flow.check_required_entity(entity, visitor.extracted_entities.d::keys);
                        if(required == true){
                            // std.out("entity ext if");
                            // visitor.respond = true;
                            visitor.next_state = -[entity_transition(entities == entity)]->[0];
                        }
                        elif(visitor.predicted_intent){
                            // std.out("entity predict else");
                            visitor.next_state = -[intent_transition(intent == visitor.predicted_intent)]->[0];
                        }
                        elif(redirect){
                            // std.out("entity redirect else");
                            // visitor.respond = true;
                            visitor.next_state = -[redirect_transition]->[0];
                        }
                        else{
                            // std.out('NOTE: Can Process else ran 2!');
                        }
                    }
                }
                elif(visitor.predicted_intent){
                    // std.out("no entity predict else");
                    visitor.next_state = -[intent_transition(intent == visitor.predicted_intent)]->[0];
                }
                elif(redirect){
                    // std.out("no entity ext else");
                    // visitor.respond = true;
                    visitor.next_state = -[redirect_transition]->[0];
                }
                else{
                    // std.out('NOTE: Can Process else ran 3!');
                }
            }
            elif(visitor.predicted_intent and visitor.threshold ){
                // std.out("predict");
            // elif(visitor.predicted_intent and visitor.threshold and !visitor.next_state){
                // std.out(intent[0]['name']);
                // visitor.next_state = -[intent_transition(intent[0]['name'] == visitor.predicted_intent)]->[0];
                // visitor.respond = true;
                visitor.next_state = -[intent_transition(intent == visitor.predicted_intent)]->[0];
            }
            elif(redirect and !visitor.next_state){
            // elif(redirect){
                // std.out("redirect");
                // visitor.respond = true;
                visitor.next_state = -[redirect_transition]->[0];
            }
            else{
                // std.out('NOTE: Can Process else ran 1!');
            //     visitor.next_state = null;
            }
        }
    }

    can nlg with talk entry {
        if (!visitor.respond) {
        // if (!visitor.respond and here.name != "dialog") {
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
        // redirect_labels = -[redirect_transition]->.edge.name;

        // if(intent_labels.length == 0 or redirect_labels.length == 0){
        if(intent_labels.length == 0){
            // std.out('set to dialog prev_state');
            visitor.prev_state = global.dialog;
        }
        else{
            // std.out('set to info_jid prev_state');
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

node dialog:dialogue_state{
    has name="dialog";

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
    //     // if (!visitor.respond and here.name != "dialog") {
    //         report {
    //             "question": visitor.question,
    //             "name": here.name,
    //             "response": visitor.response
    //         };
    //         // twilio.twilio_bot(visitor.response, visitor.phone_number);
    //     }
    // }


}

node faqs:dialogue_state{
    has name;
    has classifier;

    can use.qa_classify;

    can nlu with talk entry{
        answers = -[faq]->.answer;
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
            visitor.next_state = global.dialog;
        }
    }
    can cleanup with talk entry{

    }

}

node faq{
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
            here.prev_state = global.dialog;
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
