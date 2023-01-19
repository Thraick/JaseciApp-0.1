walker create_intent_utterance{
    has jid;
    has utterance;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t(id==jid)]-> node::intent_t else: report:custom = {"error": "jid not found!"};
    intent_t{
        take -[intent_utterance_root_t]-> node::intent_utterance_root_t else { 
            spawn here +[intent_utterance_root_t]+> node::intent_utterance_root_t; 
            take -[intent_utterance_root_t]-> node::intent_utterance_root_t;
        }
    }
    intent_utterance_root_t{
        utterance_list = -[intent_utterance_t]->.utterance;
        if !(utterance){
            report:custom = "Missing required!";
        }
        elif(utterance in utterance_list){
            report:custom = {"error": "Utterance already exist! " + utterance};
        }
        else{
            nd = spawn node::intent_utterance_t(utterance = utterance);
            here +[intent_utterance_t(id=nd.info['jid'])]+>nd;
            report:custom = {"jid":nd.info['jid'], "utterance": nd.context.utterance};
        }
    }
}

walker update_intent_utterance{
    has jid;
    has utterance;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t: take -[intent_utterance_root_t]-> node::intent_utterance_root_t;
    intent_utterance_root_t{ 
        utterance_list = -[intent_utterance_t]->.utterance;

        if !(utterance){
            report:custom = "Missing required!";
        }
        elif(utterance in utterance_list){
            report:custom = {"error": "Utterance already exist! " + utterance};
        }
        else: take -[intent_utterance_t(id==jid)]->node::intent_utterance_t else: report:custom = {"error": "jid not found!"};

    }
    intent_utterance_t{
        here.utterance = utterance;
        report:custom = custom = {"jid":here.info['jid'], "utterance": here.utterance};
    }
}

walker list_intent_utterance{
    has payload = [];

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t else: report:custom = {"error": "intent not found!"};
    intent_t: take -[intent_utterance_root_t]-> node::intent_utterance_root_t else: report:custom = {"error": "Utterance not found!"};
    intent_utterance_root_t: take --> node::intent_utterance_t;
    intent_utterance_t{
        data={};
        data['jid']=here.info['jid'];
        data['utterance']=here.utterance;
        payload.list::append(data);
    }
    with exit{
        if(payload){
            report:custom = payload;
        }
        else: report:custom = {"error": "No utterance found!"};
        
    }
}

walker get_intent_utterance{
    has payload = [];
    has jid;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t(id==jid)]-> node::intent_t else: report:custom = {"error": "jid not found!"};
    intent_t: take -[intent_utterance_root_t]-> node::intent_utterance_root_t else: report:custom = {"error": "Utterance not found!"};
    intent_utterance_root_t: take --> node::intent_utterance_t;
    intent_utterance_t{
        data={};
        data['jid']=here.info['jid'];
        data['utterance']=here.utterance;
        payload.list::append(data);
    }
    with exit{
        if(payload){
            report:custom = {"payload": payload, "error": ""};  
        }
        else: report:custom = {"payload": [], "error": "No Utterance Found!"};  
    }
}

walker delete_intent_utterance{
    has jid;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t: take -[intent_utterance_root_t]-> node::intent_utterance_root_t;
    intent_utterance_root_t: take -[intent_utterance_t(id==jid)]-> node::intent_utterance_t else: report:custom = {"error": "jid not found!"};
    intent_utterance_t{
        report:custom = "Utterance deleted!";
        destroy here;
        disengage;
    }
}
