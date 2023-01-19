walker create_intent{
    has intent;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t{
        intent_list = -[intent_t]->.intent;
        if !(intent){
            report:custom = {"payload": [], "error": "Intent required!"};  
        }
        elif(intent in intent_list){
            report:custom = {"error": "Intent already exist! " + intent, "payload": []};
        }
        else{
            nd = spawn node::intent_t(intent = intent);
            here +[intent_t(id=nd.info['jid'])]+>nd;
            payload = {"jid":nd.info['jid'], "intent": nd.context.intent};
            report:custom = {"payload": [payload], "error": ""};  
        }
    }
}

walker update_intent{
    has intent;
    has jid;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t{ 
        intent_list = -[intent_t]->.intent;
        std.out(intent_list);
        if !(intent){
            report:custom = "Missing required!";
        }
        elif(intent in intent_list){
            report:custom = {"error": "Intent already exist! " + intent};
        }
        else: take -[intent_t(id==jid)]-> node::intent_t else: report:custom = {"error": "jid not found!"};
    }
    intent_t{
        here.intent = intent;
        report:custom = custom = {"jid":here.info['jid'], "intent": here.intent};
    }
}

walker list_intent{
    has private payload = [];
    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take --> node::intent_t;
    intent_t{
        data = {};
        data['jid']=here.info['jid'];
        data["intent"]=here.intent;
        utterance_list = -[utterance_root]->;
        if(utterance_list): payload.list::append(data);
    }
    with exit{
        if(payload){
            report:custom = {"payload": payload, "error": ""};  
        }
        else: report:custom = {"payload": [], "error": "No Intent Found!"};  
        
    }
}

walker list_all_intent{
    has private payload = [];
    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take --> node::intent_t;
    intent_t{
        data = {};
        data['jid']=here.info['jid'];
        data["intent"]=here.intent;
        payload.list::append(data);
    }
    with exit{
        if(payload){
            report:custom = {"payload": payload, "error": ""};  
        }
        else: report:custom = {"payload": [], "error": "No Intent Found!"};  
    }
}

walker get_intent{
    has jid;
    has private payload = [];
    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t(id==jid)]-> node::intent_t;
    intent_t{
        data = {};
        data['jid']=here.info['jid'];
        data["intent"]=here.intent;
        payload.list::append(data);
    }
    with exit{
        if(payload){
            report:custom = {"payload": payload, "error": ""};  
        }
        else: report:custom = {"payload": [], "error": "No Intent Found!"};  
    }
}

walker delete_intent{
    has jid;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t(id==jid)]-> node::intent_t else: report:custom = {"error": "jid not found!"};
    intent_t{
        report:custom = "Intent deleted!";
        destroy here;
        disengage;
    }
}
