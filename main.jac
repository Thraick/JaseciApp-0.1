import {*} with "./graphs.jac";
import {*} with "./globals.jac";
import {*} with "./training_app/training_walkers.jac";
import {*} with "./conv_app/conv_walkers.jac";

import {*} with './utils/model/kit/bi_enc.jac';
import {*} with './utils/model/kit/tfm_ner.jac';
import {*} with './utils/model/kit/zs_classifier.jac';


walker init {
    root{
        global.main_root = here.info["jid"];

        take -[training_root_t]-> node::training_root_t else {
            spawn here +[training_root_t]+> graph::training_graph;
        }

        take -[conv_root]-> node::conv_root else {
            spawn here +[conv_root]+> node::conv_root;
            take -[conv_root]-> node::conv_root;
        }
    }
    conv_root{
        take -[dialogue_root]-> node::dialogue_root else{
            spawn here +[dialogue_root]+> graph::dialogue_root;
            spawn here +[user]+> node::user;
            spawn here walker::ingest_faq;
            take -[dialogue_root]-> node::dialogue_root;
        }
    }
    dialogue_root{
        global.dialogue_root = here.info['jid'];
    }
}