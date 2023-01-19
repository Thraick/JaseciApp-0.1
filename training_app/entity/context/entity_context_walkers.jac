walker create_entity_context{
    has jid;
    has entity_value;
    has utterance;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t: take -[intent_entity_root_t]-> node::intent_entity_root_t;
    intent_entity_root_t: take -[intent_entity_t(id==jid)]-> node::intent_entity_t else: report:custom = {"error": "jid not found!"};
    intent_entity_t{
        take -[entity_context_root_t]-> node::entity_context_root_t else { 
            spawn here +[entity_context_root_t]+> node::entity_context_root_t; 
            take -[entity_context_root_t]-> node::entity_context_root_t;
        }
    }
    entity_context_root_t{
        utterance_list = -[entity_context_t]->.utterance;
        entity_value_list = -[entity_context_t]->.entity_value;
        std.out(utterance_list);
        std.out(entity_value_list);
        if !(entity_value and utterance){
            report:custom = "Missing required!";
        }
        elif(utterance in utterance_list){
            report:custom = {"error": "utterance already exist! " + utterance};
        }
        elif(entity_value in entity_value_list and utterance in utterance_list){
            report:custom = {"error": "utterance and entity already exist! " + entity_value};
        }
        else{
            nd = spawn node::entity_context_t(utterance = utterance, entity_value= entity_value);
            here +[entity_context_t(id=nd.info['jid'])]+>nd;
            report:custom = {"jid":nd.info['jid'], "utterance": nd.context.utterance, "entity_value": nd.context.entity_value};
        }
    }
}

walker update_entity_context{
    has jid;
    has entity_value;
    has utterance;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t: take -[intent_entity_root_t]-> node::intent_entity_root_t;
    intent_entity_root_t: take -[intent_entity_t]-> node::intent_entity_t;
    intent_entity_t: take -[entity_context_root_t]-> node::entity_context_root_t;
    entity_context_root_t{
        utterance_list = -[entity_context_t]->.utterance;
        entity_value_list = -[entity_context_t]->.entity_value;
        if !(entity_value or utterance){
            report:custom = "Missing required!";
        }
        elif(utterance in utterance_list){
            report:custom = {"error": "utterance already exist! " + utterance};
        }
        elif(entity_value in entity_value_list){
            report:custom = {"error": "entity_value already exist! " + entity_value};
        }
        else: take -[entity_context_t(id==jid)]-> node::entity_context_t else: report:custom = {"error": "jid not found!"};
    }
    entity_context_t{
        if(utterance): here.utterance = utterance;
        if(entity_value): here.entity_value = entity_value;
        report:custom = {"jid":here.info['jid'], "utterance": here.utterance, "entity_value": here.entity_value};
    }
}

walker list_entity_context{
    has payload = [];

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t: take -[intent_entity_root_t]-> node::intent_entity_root_t;
    intent_entity_root_t: take -[intent_entity_t]-> node::intent_entity_t;
    intent_entity_t: take -[entity_context_root_t]-> node::entity_context_root_t;
    entity_context_root_t: take -[entity_context_t]-> node:: entity_context_t;
    entity_context_t{
        data={};
        data['jid']=here.info['jid'];
        data['entity_value']=here.entity_value;
        data['utterance']=here.utterance;
        payload.list::append(data);


        // entity = <-[entity_context_t]-<-[entity_context_root_t]-.entity;
        // utt = here.utterance;
        // value = '['+here.entity_value.str+']'+'('+entity[0].str+')';
        // utt.str::replace(here.entity_value, value);
        // payload.list::append(utt);
    }
    with exit{
        if(payload){
            report:custom = payload;
        }
        else: report:custom = {"error": "No context found!"};
    }
}

walker get_entity_context{
    has payload = [];
    has jid;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t(id==jid)]-> node::intent_t else: report:custom = {"error": "jid not found!"};
    intent_t: take -[intent_entity_root_t]-> node::intent_entity_root_t;
    intent_entity_root_t: take -[intent_entity_t]-> node::intent_entity_t;
    intent_entity_t: take -[entity_context_root_t]-> node::entity_context_root_t;
    entity_context_root_t: take -[entity_context_t]-> node:: entity_context_t;
    entity_context_t{
        entities = <-[entity_context_t]-<-[entity_context_root_t]-.entity;
        data={};
        data['jid']=here.info['jid'];
        data['entity']= entities[0];
        data['entity_value']=here.entity_value;
        data['utterance']=here.utterance;
        payload.list::append(data);
    }
    with exit{
        if(payload){
            report:custom = {"payload": payload, "error": ""};  
        }
        else: report:custom = {"payload": [], "error": "No Entity Context Found!"};  
        
    }
}

walker delete_entity_context{
    has jid;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t: take -[intent_entity_root_t]-> node::intent_entity_root_t;
    intent_entity_root_t: take -[intent_entity_t]-> node::intent_entity_t;
    intent_entity_t: take -[entity_context_root_t]-> node::entity_context_root_t;
    entity_context_root_t: take -[entity_context_t(id==jid)]-> node::entity_context_t else: report:custom = {"error": "jid not found!"};
    entity_context_t{
        report:custom = "response deleted!";
        destroy here;
        disengage;
    }
}
