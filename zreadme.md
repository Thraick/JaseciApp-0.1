Jsserv makemigrations base
Jsserv migrate
Jsserv runserver 0.0.0.0:8099

login http://0.0.0.0:8099/

jac build main.jac
sentinel set -snt active:sentinel -mode ir main.jir
walker run init



actions load module jaseci_ai_kit.zs_classifier
actions load module jaseci_ai_kit.use_qa
actions load module jaseci_ai_kit.bi_enc
actions load module jaseci_ai_kit.tfm_ner
actions load module jaseci_ai_kit.use_enc
actions load local utils/model/local/flow.py
actions load local utils/model/local/twilio_bot.py
actions load local utils/model/local/local_module.py

graph delete active:graph
jac build main.jac
graph create -set_active true
sentinel register -set_active true -mode ir main.jir

walker run init


graph get -mode dot -o .main.dot
dot -Tpng .main.dot -o .main.png

pip install jaseci --upgrade
pip install jaseci-ai-kit --upgrade
pip install jaseci-serv --upgrade



walker run ingest_faq

walker run create_node_and_edge -ctx "{ \"intent\":\"greetings\",   \"template\":\"response_only\"}"
walker run create_node_and_edge -ctx "{ \"intent\":\"goodbye\",     \"template\":\"response_only\"}"
walker run create_node_and_edge -ctx "{ \"intent\":\"account\",     \"template\":\"collect_info\"}"

walker run create_node_and_edge -ctx "{ \"first_node\":\"urn:uuid:450c75d7-1f02-43e0-970b-89e456a3e4eb\",   \"name\":\"number\", \"template\":\"extract_info\"}"
walker run create_node_and_edge -ctx "{ \"first_node\":\"urn:uuid:99cf4389-a6a3-43d5-8819-5deb532a9415\",   \"second_node\":\"urn:uuid:d9424273-2966-465c-9c99-a40efd0a3a64\", \"intent\":\"faq_root\"}"

walker run create_node_and_edge -ctx "{ \"first_node\":\"urn:uuid:99cf4389-a6a3-43d5-8819-5deb532a9415\",   \"second_node\":\"urn:uuid:99cf4389-a6a3-43d5-8819-5deb532a9415\", \"name\":\"number\"}"
walker run create_node_and_edge -ctx "{ \"first_node\":\"urn:uuid:99cf4389-a6a3-43d5-8819-5deb532a9415\",   \"second_node\":\"urn:uuid:450c75d7-1f02-43e0-970b-89e456a3e4eb\", \"entities\": [\"number\"]}"



