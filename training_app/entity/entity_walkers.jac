walker create_intent_entity{
    has jid;
    has entity;
    has anchor load_response;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t(id==jid)]-> node::intent_t else: report:custom = {"error": "jid not found!"};
    intent_t{
        take -[intent_entity_root_t]-> node::intent_entity_root_t else { 
            spawn here +[intent_entity_root_t]+> node::intent_entity_root_t; 
            take -[intent_entity_root_t]-> node::intent_entity_root_t;
        }
    }
    intent_entity_root_t{
        entity_list = -[intent_entity_t]->.entity;
        if !(entity){
            report:custom = "Missing required!";
        }
        elif(entity in entity_list){
            report:custom = {"error": "entity already exist! " + entity};
        }
        else{
            nd = spawn node::intent_entity_t(entity = entity);
            here +[intent_entity_t(id=nd.info['jid'])]+>nd;
            report:custom = {"jid":nd.info['jid'], "entity": nd.context.entity};
            if (load_response){
                for response in load_response[entity]{
                    // std.out("entity response\n\n");
                    // std.out(response);
                    spawn *(global.main_root) walker::create_entity_response(jid=nd.info['jid'], response=response);
                }
            }
        }
    }
}

walker update_intent_entity{
    has jid;
    has entity;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t: take -[intent_entity_root_t]-> node::intent_entity_root_t;
    intent_entity_root_t{ 
        entity_list = -[intent_entity_t]->.entity;

        if !(entity){
            report:custom = "Missing required!";
        }
        elif(entity in entity_list){
            report:custom = {"error": "entity already exist! " + entity};
        }
        else: take -[intent_entity_t(id==jid)]->node::intent_entity_t else: report:custom = {"error": "jid not found!"};

    }
    intent_entity_t{
        here.entity = entity;
        report:custom = custom = {"jid":here.info['jid'], "entity": here.entity};
    }
}

walker list_intent_entity{
    has payload = [];

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t else: report:custom = {"error": "intent not found!"};
    intent_t: take -[intent_entity_root_t]-> node::intent_entity_root_t else: report:custom = {"error": "entity not found!"};
    intent_entity_root_t: take -[intent_entity_t]-> node::intent_entity_t;
    intent_entity_t{
        data={};
        data['jid']=here.info['jid'];
        data['entity']=here.entity;
        payload.list::append(data);
    }
    with exit{
        if(payload){
            report:custom = {"payload": payload, "error": ""};  
        }
        else: report:custom = {"payload": [], "error": "No Entity Found!"};  
    }
}

walker get_intent_entity{
    has payload = [];
    has jid;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t(id==jid)]-> node::intent_t else: report:custom = {"error": "jid not found!"};
    intent_t: take -[intent_entity_root_t]-> node::intent_entity_root_t else: report:custom = {"error": "entity not found!"};
    intent_entity_root_t: take -[intent_entity_t]-> node::intent_entity_t;
    intent_entity_t{
        data={};
        data['jid']=here.info['jid'];
        data['entity']=here.entity;
        payload.list::append(data);
    }
    with exit{
        if(payload){
            report:custom = {"payload": payload, "error": ""};  
        }
        else: report:custom = {"payload": [], "error": "No Entity Found!"};  
        
    }
}

walker get_intent_entity_list{
    has anchor payload = [];
    has jid;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t(id==jid)]-> node::intent_t else: report:custom = {"error": "jid not found!"};
    intent_t: take -[intent_entity_root_t]-> node::intent_entity_root_t else: report:custom = {"error": "entity not found!"};
    intent_entity_root_t: take -[intent_entity_t]-> node::intent_entity_t;
    intent_entity_t{
        // data={};
        // data['jid']=here.info['jid'];
        // data['entity']=here.entity;
        payload.list::append(here.entity);
    }
    with exit{
        if(payload){
            report:custom = {"payload": payload, "error": ""};  
        }
        else: report:custom = {"payload": [], "error": "No Entity Found!"};  
        
    }
}

walker delete_intent_entity{
    has jid;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t: take -[intent_entity_root_t]-> node::intent_entity_root_t;
    intent_entity_root_t: take -[intent_entity_t(id==jid)]-> node::intent_entity_t else: report:custom = {"error": "jid not found!"};
    intent_entity_t{
        report:custom = "entity deleted!";
        destroy here;
        disengage;
    }
}
