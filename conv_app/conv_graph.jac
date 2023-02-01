import {*} with "./conv_node.jac";
import {*} with "./conv_edge.jac";


graph dialogue_system {
    has anchor dialog;

    // can file.load_json;
    spawn {
        bienc = file.load_json(global.train_classifer_path);

        dialog = spawn node::dialog;

        faq_root = spawn node::faqs(imprint = [{"list_imprint": bienc['faq_root'], "name": "faq_root"}], name="faq_root");
        dialog +[intent_transition(intent="faq_root")]+>faq_root;

        soc = spawn node::response_only_template(imprint = [{"list_imprint":bienc['greetings'], "name": "greetings"}], name="greetings");
        dialog +[intent_transition(intent="greetings")]+>soc;

        eoc = spawn node::response_only_template(imprint = [{"list_imprint":bienc['goodbye'], "name": "goodbye"}], name="goodbye");
        dialog +[intent_transition(intent="goodbye")]+>eoc;

    }
}


