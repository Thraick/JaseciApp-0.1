import {*} with "./utterance/utterance_walkers.jac";
import {*} with "./faq/faq_walkers.jac";
import {*} with "./state/response/response_walkers.jac";
import {*} with "./state/resource/resource_walkers.jac";
import {*} with "./state/intent/intent_walkers.jac";
import {*} with "./entity/entity_walkers.jac";
import {*} with "./entity/context/entity_context_walkers.jac";
import {*} with "./entity/response/entity_response_walkers.jac";


walker upload_intent{
    has payload = {};

    can file.dump_json;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t{
        intent = here.intent;
        utterance = -[intent_utterance_root_t]->-[intent_utterance_t]->.utterance;
        if(intent and utterance): payload[intent]=utterance;
    }
    with exit{
        if(payload){ 
            file.dump_json(global.train_classifer_path, payload);
            report:custom = payload;
        }
        else: report:custom = "no intent found!";
    }
}


walker upload_state{
    has payload = [];

    can file.dump_json;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t{
        id = here.info['jid'];
        response_list = spawn *(global.main_root) walker::get_intent_response_list(jid=id);

        entity_list = spawn *(global.main_root) walker::get_intent_entity_list(jid=id);
        entity_response_list = spawn *(global.main_root) walker::get_entity_response_list(jid=id);

        variable_list = spawn *(global.main_root) walker::get_intent_resource_root(jid=id);
        resource_str = spawn *(global.main_root) walker::get_info_item_root_str(jid=id);

        extracted_item_dict = {};
        if (entity_list.type == list){
            for i=0 to i<entity_list.length by i+=1 {
                if (entity_response_list.type == list): extracted_item_dict[entity_list[i]]=entity_response_list[i];
                else: extracted_item_dict[entity[i]]=[];
            }
        }

        for i=0 to i<entity_list.length by i+=1 {
            if (entity_response_list.type == list): extracted_item_dict[entity_list[i]]=entity_response_list[i];
            else: extracted_item_dict[entity[i]]=[];
        }

        data = {};
        data['name'] = here.intent;
        data['responses'] = [];
        data['extracted_item'] = {};
        data['variable'] = [];
        data['resource'] = '';

        if (response_list.type == list): data['responses'] = response_list;
        if (extracted_item_dict): data['extracted_item'] = extracted_item_dict;
        if (variable_list.type == list): data['variable'] = variable_list;
        if (resource_str.type == str and resource_str != ""): data['resource'] = resource_str;

        if (response_list or extracted_item_dict or variable_list or resource_str): payload.list::append(data);
    }
    with exit{
        if(payload){ 
            file.dump_json(global.train_state_path, payload);
            report:custom = payload;
        }
        else: report:custom = "no intent found!";
    }
}

walker upload_tfm{
    has payload = [];

    can file.dump_json;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t: take -[intent_entity_root_t]-> node::intent_entity_root_t;
    intent_entity_root_t: take -[intent_entity_t]-> node::intent_entity_t;
    intent_entity_t: take -[entity_context_root_t]-> node::entity_context_root_t;
    entity_context_root_t: take -[entity_context_t]-> node::entity_context_t;
    entity_context_t{

        entity = <-[entity_context_t]-<-[entity_context_root_t]-.entity;
        utt = here.entity_utterance;
        value = '['+here.entity_value.str+']'+'('+entity[0].str+')';
        utt.str::replace(here.entity_value, value);
        payload.list::append(utt);
    }
    with exit{
        if(payload){
            file.dump_json(global.train_tfn_ner_path, payload);
            report:custom = payload;
        }
        else: report:custom = {"error": "No context found!"};
    }
}

walker upload_faq{
    has payload = [];
    has res;
    
    can file.dump_json;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[faq_root_t]-> node::faq_root_t;
    faq_root_t: take -[faq_state_t]-> node::faq_state_t;
    faq_state_t{
        data = {};
        data["question"]=here.question;
        data["answer"]=here.answer;
        payload.list::append(data);
    }
    with exit{
        if(payload){
            file.dump_json(global.train_faq_answer_path, payload);
            report:custom = payload;
        }
        else: report:custom = {"error": "No faq found!"};
    }
}


walker load_intent{
    has payload = [];
    has json_data;
    
    can file.load_json;
    
    with entry{
        json_data = file.load_json(global.train_classifer_path);
        for intent in json_data{
            spawn *(global.main_root) walker::create_intent(intent=intent);
            // std.out("jid\n");
            // std.out(nd.info['jid']);
            // for utterance in json_data[intent]{
            //     spawn *(global.main_root) walker::create_state_utterance(jid = nd.info['jid'], utterance=utterance);
            // }
        }
    }

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t{
        for intent in json_data{
            if(here.intent == intent){
                for utterance in json_data[intent]{
                    spawn *(global.main_root) walker::create_intent_utterance(jid = here.info['jid'], utterance=utterance);
                }
            }
        }
    }
    with exit{
        report:custom = "Intent loaded!";
    }
    
}

walker load_state{
    has payload = [];
    has json_data;
    
    can file.load_json;
    
    with entry{
        json_data = file.load_json(global.train_state_path);
    }

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t{
        intent_list = -[intent_t]->.intent;
        std.out(intent_list);
        for state in json_data{
            if!(state.name in intent_list){
                spawn *(global.main_root) walker::create_intent(intent=state.name);
            }
        }
        take -[intent_t]->node::intent_t;
    }
   intent_t{
        for state in json_data{
            if(here.intent == state.name){
                for response in state['responses']{
                    spawn *(global.main_root) walker::create_intent_response(jid = here.info['jid'], response=response);
                }
                for entity in state['extracted_item']{
                    spawn *(global.main_root) walker::create_intent_entity(jid= here.info['jid'], entity = entity, load_response=state['extracted_item']);
                }
                if(state['resource']){
                    info_jid = spawn *(global.main_root) walker::create_intent_resource_root(jid = here.info['jid'], resource=state['resource']);
                    // std.out("info_jid");
                    // std.out(info_jid);
                    // for info_item in state['variable']{
                    //     std.out(info_item);
                    //     std.out(info_jid);
                    //     spawn *(global.main_root) walker::create_state_info_item(jid= here.info['jid'], info_item=info_item);
                    // }
                }
                if(state['variable']){
                    jid = -[intent_resource_root_t]->.edge.id;
                    std.out("jid\n");
                    std.out(jid[0]);
                    for variable in state['variable']{
                        spawn *(global.main_root) walker::create_variable(jid= jid[0], variable=variable);
                    }
                }

            }
        }
        // take -[info_item_root]-> node::info_item_root;
    }
    // info_item_root{
    //     spawn *(global.main_root) walker::create_state_info_item(jid= here.info['jid'], info_item=info_item);
    // }
    with exit{
        report:custom = "state loaded!";
    }
}

walker load_tfm{
    has payload = [];
    has res;
    
    can file.load_json;
    can local.entity_value;
    
    with entry{
        json_data = file.load_json(global.train_tfn_ner_path);
        res = local.entity_value(null, json_data);
        std.out(res);
    }


    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t: take -[intent_entity_root_t]-> node::intent_entity_root_t;
    intent_entity_root_t: take -[intent_entity_t]-> node::intent_entity_t;
    intent_entity_t{
        for tfm in res{
            std.out(tfm);
            if(here.entity == tfm.entity){
                spawn *(global.main_root) walker::create_entity_context(jid= here.info['jid'], utterance= tfm.utterance, entity_value= tfm.value);
            }
        }
    }
    with exit{
        report:custom = "Entity context loaded!";
    }
}

walker load_faq{
    has payload = [];
    has json_data;
    
    can file.load_json;
    
    with entry{
        json_data = file.load_json(global.train_faq_answer_path);
    }

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[faq_root_t]-> node::faq_root_t;
    faq_root_t{
        for item in json_data{
            spawn *(global.main_root) walker::create_faq(question=item.question, answer=item.answer);
        }
    }
    with exit{
        report:custom = "Faq loaded!";
    }
}