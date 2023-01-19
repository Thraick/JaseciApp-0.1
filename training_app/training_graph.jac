import {*} with "./utterance/utterance_graph.jac";
import {*} with "./faq/faq_graph.jac";
import {*} with "./state/response/response_graph.jac";
import {*} with "./state/resource/resource_graph.jac";
import {*} with "./state/intent/intent_graph.jac";
import {*} with "./entity/entity_graph.jac";
import {*} with "./entity/context/entity_context_graph.jac";
import {*} with "./entity/response/entity_response_graph.jac";


node training_root_t;
edge training_root_t;


graph training_graph {
    has anchor training_root_t;
    spawn {
        training_root_t = spawn node::training_root_t;

        intent_root_t = spawn training_root_t +[intent_root_t]+> node::intent_root_t;
        faq_root_t = spawn training_root_t +[faq_root_t]+> node::faq_root_t;
    }
}