import {*} with "./conv_node.jac";
import {*} with "./conv_edge.jac";


graph dialogue_root {
    has anchor dialogue_root;

    // can file.load_json;
    spawn {
        bienc = file.load_json(global.train_classifer_path);

        dialogue_root = spawn node::dialogue_root;

        faq_root = spawn node::faq_root(imprint = [{"list_imprint": bienc['faq_root'], "name": "faq_root"}], name="faq_root");
        dialogue_root +[intent_transition(intent="faq_root")]+>faq_root;

        // soc = spawn node::soc(imprint = [{"list_imprint":bienc['greetings'], "name": "greetings"}]);
        // dialogue_root +[intent_transition(intent="greetings")]+>soc;

        // eoc = spawn node::eoc(imprint = [{"list_imprint":bienc['goodbye'], "name": "goodbye"}]);
        // dialogue_root +[intent_transition(intent="goodbye")]+>eoc;
    }
}


