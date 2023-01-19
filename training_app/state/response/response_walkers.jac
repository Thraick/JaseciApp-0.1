
## response
walker create_intent_response{
    has jid;
    has response;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t(id==jid)]-> node::intent_t else: report:custom = {"error": "jid not found!"};
    intent_t{
        take -[intent_response_root_t]-> node::intent_response_root_t else { 
            spawn here +[intent_response_root_t]+> node::intent_response_root_t; 
            take -[intent_response_root_t]-> node::intent_response_root_t;
        }
    }
    intent_response_root_t{
        response_list = -[intent_response_t]->.response;
        if !(response){
            report:custom = "Missing required!";
        }
        elif(response in response_list){
            report:custom = {"error": "response already exist! " + response};
        }
        else{
            nd = spawn node::intent_response_t(response = response);
            here +[intent_response_t(id=nd.info['jid'])]+>nd;
            report:custom = {"jid":nd.info['jid'], "response": nd.context.response};
        }
    }
}

walker update_intent_response{
    has jid;
    has response;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t: take -[intent_response_root_t]-> node::intent_response_root_t;
    intent_response_root_t{ 
        response_list = -[intent_response_t]->.response;

        if !(response){
            report:custom = "Missing required!";
        }
        elif(response in response_list){
            report:custom = {"error": "response already exist! " + response};
        }
        else: take -[intent_response_t(id==jid)]->node::intent_response_t else: report:custom = {"error": "jid not found!"};

    }
    intent_response_t{
        here.response = response;
        report:custom = custom = {"jid":here.info['jid'], "response": here.response};
    }
}

walker list_intent_response{
    has payload = [];

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t else: report:custom = {"error": "intent not found!"};
    intent_t: take -[intent_response_root_t]-> node::intent_response_root_t else: report:custom = {"error": "response not found!"};
    intent_response_root_t: take -[intent_response_t]-> node::intent_response_t;
    intent_response_t{
        intent = <-[intent_response_t]-<-[intent_response_root_t]-.intent;
        data={};
        data['jid']=here.info['jid'];
        data['intent']=intent[0];
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

walker get_intent_response{
    has payload = [];
    has jid;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t(id==jid)]-> node::intent_t else: report:custom = {"error": "jid not found!"};
    intent_t: take -[intent_response_root_t]-> node::intent_response_root_t else: report:custom = {"error": "response not found!"};
    intent_response_root_t: take -[intent_response_t]-> node::intent_response_t;
    intent_response_t{
        intent = <-[intent_response_t]-<-[intent_response_root_t]-.intent;
        data={};
        data['jid']=here.info['jid'];
        data['intent']=intent[0];
        data['response']=here.response;
        payload.list::append(data);
    }
    with exit{
        if(payload){
            report:custom = {"payload": payload, "error": ""};  
        }
        else: report:custom = {"payload": [], "error": "No Response Found!"};  
        
    }
}

walker get_intent_response_list{
    has anchor payload = [];
    has jid;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t(id==jid)]-> node::intent_t else: report:custom = {"error": "jid not found!"};
    intent_t: take -[intent_response_root_t]-> node::intent_response_root_t else: report:custom = {"error": "response not found!"};
    intent_response_root_t: take --> node::intent_response_t;
    intent_response_t{
        // data={};
        // data['jid']=here.info['jid'];
        // data['response']=here.response;
        payload.list::append(here.response);
    }
    with exit{
        if(payload){
            report:custom = payload;
        }
        else: report:custom = {"error": "No response found!"};
        
    }
}

walker delete_intent_response{
    has jid;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t: take -[intent_response_root_t]-> node::intent_response_root_t;
    intent_response_root_t: take -[intent_response_t(id==jid)]-> node::intent_response_t else: report:custom = {"error": "jid not found!"};
    intent_response_t{
        report:custom = "response deleted!";
        destroy here;
        disengage;
    }
}