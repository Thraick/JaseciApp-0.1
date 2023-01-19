
## resource
walker create_variable{
    has jid;
    has variable;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t: take -[intent_resource_root_t(id==jid)]-> node::intent_resource_root_t else: report:custom = {"error": "jid not found!"};
    intent_resource_root_t{
        variable_list = -[intent_variable_t]->.variable;
        if !(variable){
            report:custom = "Missing required!";
        }
        elif(variable in variable_list){
            report:custom = {"error": "variable already exist! " + variable};
        }
        else{
            nd = spawn node::intent_variable_t(variable = variable);
            here +[intent_variable_t(id=nd.info['jid'])]+>nd;
            report:custom = {"jid":nd.info['jid'], "variable": nd.context.variable};
        }
    }
}

walker update_variable{
    has jid;
    has variable;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t: take -[intent_resource_root_t]-> node::intent_resource_root_t;
    intent_resource_root_t{ 
        variable_list = -[intent_variable_t]->.variable;

        if !(variable){
            report:custom = "Missing required!";
        }
        elif(variable in variable_list){
            report:custom = {"error": "variable already exist! " + variable};
        }
        else: take -[intent_variable_t(id==jid)]->node::intent_variable_t else: report:custom = {"error": "jid not found!"};

    }
    intent_variable_t{
        here.variable = variable;
        report:custom = custom = {"jid":here.info['jid'], "variable": here.variable};
    }
}

walker list_variable{
    has payload = [];

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t else: report:custom = {"error": "intent not found!"};
    intent_t: take -[intent_resource_root_t]-> node::intent_resource_root_t else: report:custom = {"error": "variable not found!"};
    intent_resource_root_t: take -[intent_variable_t]-> node::intent_variable_t;
    intent_variable_t{
        data={};
        data['jid']=here.info['jid'];
        data['variable']=here.variable;
        payload.list::append(data);
    }
    with exit{
        if(payload){
            report:custom = payload;
        }
        else: report:custom = {"error": "No variable found!"};
        
    }
}

walker get_variable{
    has payload = [];
    has jid;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t(id==jid)]-> node::intent_t else: report:custom = {"error": "jid not found!"};
    intent_t: take -[intent_resource_root_t]-> node::intent_resource_root_t else: report:custom = {"error": "variable not found!"};
    intent_resource_root_t: take -[intent_variable_t]-> node::intent_variable_t;
    intent_variable_t{
        data={};
        data['jid']=here.info['jid'];
        data['variable']=here.variable;
        payload.list::append(data);
    }
    with exit{
        if(payload){
            report:custom = payload;
        }
        else: report:custom = {"error": "No variable found!"};
        
    }
}

walker get_variable_list{
    has anchor payload = [];
    has jid;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t(id==jid)]-> node::intent_t else: report:custom = {"error": "jid not found!"};
    intent_t: take -[intent_resource_root_t]-> node::intent_resource_root_t else: report:custom = {"error": "variable not found!"};
    intent_resource_root_t: take -[intent_variable_t]-> node::intent_variable_t;
    intent_variable_t{
        payload.list::append(here.variable);
    }
    with exit{
        if(payload){
            report:custom = payload;
        }
        else: report:custom = {"error": "No variable found!"};
        
    }
}

walker delete_variable{
    has jid;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t: take -[intent_resource_root_t]-> node::intent_resource_root_t;
    intent_resource_root_t: take -[intent_variable_t(id==jid)]-> node::intent_variable_t else: report:custom = {"error": "jid not found!"};
    intent_variable_t{
        report:custom = "variable deleted!";
        destroy here;
        disengage;
    }
}

## info item root
walker create_intent_resource_root{
    has anchor jid;
    has resource;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t(id==jid)]-> node::intent_t else: report:custom = {"error": "jid not found!"};
    intent_t{
        resource_list = -[intent_resource_root_t]->.resource;
        if !(resource){
            report:custom = "Missing required!";
        }
        elif(resource in resource_list){
            report:custom = {"error": "resource already exist! " + resource};
        }
        elif(resource_list.length >= 1){
            report:custom = {"error": "more than one resource exist! Please update the previous one." + resource_list[0].str};
        }
        else{
            nd = spawn node::intent_resource_root_t(resource = resource);
            here +[intent_resource_root_t(id=nd.info['jid'])]+>nd;
            report:custom = {"jid":nd.info['jid'], "resource": nd.context.resource};
            std.out("nd.info['jid']");
            std.out(nd.info['jid']);
        }
    }
}

walker update_intent_resource_root{
    has jid;
    has resource;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t{
        resource_list = -[intent_resource_root_t]->.resource;
        if !(resource){
            report:custom = "Missing required!";
        }
        elif(resource in resource_list){
            report:custom = {"error": "resource already exist! " + resource};
        }
        else{
            take -[intent_resource_root_t(id==jid)]-> node::intent_resource_root_t else: report:custom = {"error": "jid not found!"};
        }
    }
    intent_resource_root_t{
        here.resource = resource;
        report:custom = custom = {"jid":here.info['jid'], "resource": here.resource};
    }
}

walker list_intent_resource_root{
    has payload = [];

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t: take -[intent_resource_root_t]-> node::intent_resource_root_t;
    intent_resource_root_t{
        data = {};
        data['jid']=here.info['jid'];
        data["resource"]=here.resource;
        payload.list::append(data);
    }
    with exit{
        if(payload){
            report:custom = payload;
        }
        else: report:custom = {"error": "No resource found!"};
    }
}

walker get_intent_resource_root{
    has payload = [];
    has jid;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t(id==jid)]-> node::intent_t;
    intent_t: take -[intent_resource_root_t]-> node::intent_resource_root_t;
    intent_resource_root_t{
        data = {};
        data['jid']=here.info['jid'];
        data["resource"]=here.resource;
        payload.list::append(data);
    }
    with exit{
        if(payload){
            report:custom = payload;
        }
        else: report:custom = {"error": "No resource found!"};
    }
}

walker get_intent_resource_root_str{
    has anchor payload = "";
    has jid;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t(id==jid)]-> node::intent_t;
    intent_t: take -[intent_resource_root_t]-> node::intent_resource_root_t;
    intent_resource_root_t{
        // data = {};
        // data['jid']=here.info['jid'];
        // data["resource"]=here.resource;
        // payload.list::append(data);
        payload=here.resource;
    }
    with exit{
        if(payload){
            report:custom = payload;
        }
        else: report:custom = {"error": "No resource found!"};
    }
}

walker delete_intent_resource_root{
    has jid;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[intent_root_t]-> node::intent_root_t;
    intent_root_t: take -[intent_t]-> node::intent_t;
    intent_t: take -[intent_resource_root_t(id==jid)]-> node::intent_resource_root_t else: report:custom = {"error": "jid not found!"};
    intent_resource_root_t{
        report:custom = "resource deleted!";
        destroy here;
        disengage;
    }
}


