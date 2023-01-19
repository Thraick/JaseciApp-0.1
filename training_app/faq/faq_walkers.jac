
walker create_faq{
    has question;
    has answer;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[faq_root_t]-> node::faq_root_t;
    faq_root_t{
        question_list = -[faq_state_t]->.question;
        answer_list = -[faq_state_t]->.answer;
        if !(question and answer){
            report:custom = {"payload": [], "error": "parameter is required!"};  
        }
        elif(question in question_list){
            report:custom = {"error": "Question already exist! " + question, "payload": []};
        }
        elif(answer in answer_list){
            report:custom = {"error": "Answer already exist! " + answer, "payload": []};
        }
        else{
            std.out(question);
            std.out(answer);
            nd = spawn node::faq_state_t(question = question, answer = answer);
            here +[faq_state_t(id=nd.info['jid'])]+>nd;
            payload = {"jid":nd.info['jid'], "question": nd.context.question, "answer": nd.context.answer};
            report:custom = {"payload": [payload], "error": ""};  
        }
    }
}

walker update_faq{
    has question;
    has answer;
    has jid;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[faq_root_t]-> node::faq_root_t;
    faq_root_t{ 
        std.out(question);
        std.out(answer);
        question_list = -[faq_state_t]->.question;
        answer_list = -[faq_state_t]->.answer;
        if !(question or answer){
            report:custom = {"payload": [], "error": "parameter is required!"};  
        }
        elif(question in question_list and answer in answer_list){
            ques = "Faq already exist! " + question.str;
            report:custom = {"error": ques, "payload": []};
        }
        else: take -[faq_state_t(id==jid)]-> node::faq_state_t else: report:custom = {"error": "jid not found!"};
    }
    faq_state_t{
        if(question): here.question = question;
        if(answer): here.answer = answer;
        std.out(question);
        std.out(answer);
        payload = {"jid":here.info['jid'], "question": here.question, "answer": here.answer};
        report:custom = {"payload": [payload], "error": ""};  
    }
}

walker list_faq{
    has private payload = [];
    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[faq_root_t]-> node::faq_root_t;
    faq_root_t: take -[faq_state_t]-> node::faq_state_t;
    faq_state_t{
        data = {};
        data['jid']=here.info['jid'];
        data["question"]=here.question;
        data["answer"]=here.answer;
        payload.list::append(data);
    }
    with exit{
        if(payload){
            report:custom = {"payload": payload, "error": ""};  
        }
        else: report:custom = {"payload": [], "error": "No FAQ Found!"};  
    }
}

walker get_faq{
    has jid;
    has private payload = [];

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[faq_root_t]-> node::faq_root_t;
    faq_root_t: take -[faq_state_t(id==jid)]-> node::faq_state_t;
    faq_state_t{
        data = {};
        data['jid']=here.info['jid'];
        data["question"]=here.question;
        data["answer"]=here.answer;
        payload.list::append(data);
    }
    with exit{
        if(payload){
            report:custom = {"payload": payload, "error": ""};  
        }
        else: report:custom = {"payload": [], "error": "No FAQ Found!"};  
    }
}

walker delete_faq{
    has jid;

    root: take -[training_root_t]-> node::training_root_t;
    training_root_t: take -[faq_root_t]-> node::faq_root_t;
    faq_root_t: take -[faq_state_t(id==jid)]-> node::faq_state_t else: report:custom = {"error": "jid not found!"};
    faq_state_t{
        report:custom = "Faq deleted!";
        destroy here;
        disengage;
    }
}


