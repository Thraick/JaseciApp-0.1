walker create_entity_response{
    has jid;
    has response;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t: take -[intent_entity_root_t]-> node::intent_entity_root_t;
    // intent_entity_root_t: take --> node::intent_entity_t;
    intent_entity_root_t: take -[intent_entity_t(id==jid)]-> node::intent_entity_t else: report:custom = {"error": "jid not found!"};
    intent_entity_t{
        take -[entity_response_root_t]-> node::entity_response_root_t else { 
            spawn here +[entity_response_root_t]+> node::entity_response_root_t; 
            take -[entity_response_root_t]-> node::entity_response_root_t;
        }
    }
    entity_response_root_t{
        response_list = -[entity_response_t]->.response;
        if !(response){
            report:custom = "Missing required!";
        }
        elif(response in response_list){
            report:custom = {"error": "response already exist! " + response};
        }
        else{
            nd = spawn node::entity_response_t(response = response);
            here +[entity_response_t(id=nd.info['jid'])]+>nd;
            report:custom = {"jid":nd.info['jid'], "response": nd.context.response};
        }
    }

}

walker update_entity_response{
    has jid;
    has response;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t: take -[intent_entity_root_t]-> node::intent_entity_root_t;
    intent_entity_root_t: take -[intent_entity_t]-> node::intent_entity_t;
    intent_entity_t: take -[entity_response_root_t]-> node::entity_response_root_t;
    entity_response_root_t{
        response_list = -[entity_response_t]->.response;
        if !(response){
            report:custom = "Missing required!";
        }
        elif(response in response_list){
            report:custom = {"error": "response already exist! " + response};
        }
        else: take -[entity_response_t(id==jid)]-> node::entity_response_t else: report:custom = {"error": "jid not found!"};
    }
    entity_response_t{
        here.response = response;
        report:custom = {"jid":here.info['jid'], "response": here.response};
    }
}

walker list_entity_response{
    has payload = [];
    has intents;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    // intent_t: take --> node::intent_entity_root_t;
    intent_t{
        intents = here.intent;
        take -[intent_entity_root_t]-> node::intent_entity_root_t;
    }
    intent_entity_root_t: take -[intent_entity_t]-> node::intent_entity_t;
    intent_entity_t: take -[entity_response_root_t]-> node::entity_response_root_t;
    entity_response_root_t: take -[entity_response_t]-> node::entity_response_t;
    entity_response_t{
        data={};
        data['jid']=here.info['jid'];
        data['intent']=intents;
        data['response']=here.response;
        payload.list::append(data);
    }
    with exit{
        if(payload){
            report:custom = payload;
        }
        else: report:custom = {"error": "No response found!"};   
    }
}

walker get_entity_response{
    has jid;
    has payload = [];

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t(id==jid)]-> node::intent_t else: report:custom = {"error": "jid not found!"};
    intent_t: take -[intent_entity_root_t]-> node::intent_entity_root_t;
    intent_entity_root_t: take -[intent_entity_t]-> node::intent_entity_t;
    intent_entity_t: take -[entity_response_root_t]-> node::entity_response_root_t;
    entity_response_root_t: take -[entity_response_t]-> node::entity_response_t;
    entity_response_t{
        entity = <-[entity_response_t]-<-[entity_response_root_t]-.entity;
        data={};
        data['jid']=here.info['jid'];
        data['intent']=entity[0];
        data['response']=here.response;
        payload.list::append(data);
    }
    with exit{
        if(payload){
            report:custom = {"payload": payload, "error": ""};  
        }
        else: report:custom = {"payload": [], "error": "No Entity Response Found!"};  
    }
}

walker get_entity_response_list{
    has jid;
    has anchor payload = [];

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t(id==jid)]-> node::intent_t else: report:custom = {"error": "jid not found!"};
    intent_t: take -[intent_entity_root_t]-> node::intent_entity_root_t;
    intent_entity_root_t: take -[intent_entity_t]-> node::intent_entity_t;
    intent_entity_t: take -[entity_response_root_t]-> node::entity_response_root_t;
    entity_response_root_t{
        res = -[entity_response_t]->.response;
        payload.list::append(res);
    }
    with exit{
        if(payload){
            report:custom = payload;
        }
        else: report:custom = {"error": "No response found!"};   
    }
}

walker delete_entity_response{
    has jid;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t: take -[intent_entity_root_t]-> node::intent_entity_root_t;
    intent_entity_root_t: take -[intent_entity_t]-> node::intent_entity_t;
    intent_entity_t: take -[entity_response_root_t]-> node::entity_response_root_t;
    entity_response_root_t: take -[entity_response_t(id==jid)]-> node::entity_response_t else: report:custom = {"error": "jid not found!"};
    entity_response_t{
        report:custom = "response deleted!";
        destroy here;
        disengage;
    }
}

