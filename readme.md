
## load
walker run load_intent
walker run load_state
walker run load_tfm
walker run load_faq

## upload
walker run upload_intent
walker run upload_state
walker run upload_tfm
walker run upload_faq


## intent - create intent
walker run create_intent -ctx "{\"intent\":\"eoc\"}"
walker run update_intent -ctx "{\"jid\":\"urn:uuid:1be85925-1b81-4645-b306-a172ed1bcb5c\", \"intent\":\"account\"}"
walker run list_intent
walker run list_all_intent
walker run delete_intent -ctx "{\"jid\":\"urn:uuid:1be85925-1b81-4645-b306-a172ed1bcb5c\"}"

## utterance - create utterance for intent
walker run create_state_utterance -ctx "{\"jid\":\"urn:uuid:b31878e5-a583-4fcb-9626-f6247445442c\", \"utterance\":\"Bye\"}"
walker run update_state_utterance -ctx "{\"jid\":\"urn:uuid:22ba3e1c-54ed-456e-b1af-69333a215ccf\", \"utterance\":\"hello\"}"
walker run get_intent_utterance -ctx "{\"jid\":\"urn:uuid:c214f07d-8a3b-49e2-9712-f57d7aa5c33e\"}"
walker run list_intent_utterance
walker run delete_intent_utterance -ctx "{\"jid\":\"urn:uuid:22ba3e1c-54ed-456e-b1af-69333a215ccf\"}"

## response - create response for intent
walker run create_state_response -ctx "{\"jid\":\"urn:uuid:fb050627-6603-458c-8044-7840bf8e4b30\", \"response\":\"Bye\"}"
walker run update_state_response -ctx "{\"jid\":\"urn:uuid:d94c8750-c912-456c-9e67-023d91030f78\", \"response\":\"hello\"}"
walker run get_intent_response -ctx "{\"jid\":\"urn:uuid:0cfc1418-9b68-4508-a108-d922dfa67710\"}"
walker run list_intent_response
walker run delete_intent_response -ctx "{\"jid\":\"urn:uuid:d2459df3-1ca0-42f5-8822-3efd78f65bfc\"}"

## entity - create entity for intent
walker run create_intent_entity -ctx "{\"jid\":\"urn:uuid:9eef0941-f5bb-4779-a5d6-bf240567c0cc\", \"entity\":\"haircut_style\"}"
walker run update_intent_entity -ctx "{\"jid\":\"urn:uuid:83461a8c-997b-4b94-a430-05d2f9bba90c\", \"entity\":\"hello\"}"
walker run get_intent_entity -ctx "{\"jid\":\"urn:uuid:82d9c4fc-3e92-45f2-ba88-3a7116a036e7\"}"
walker run list_intent_entity
walker run delete_intent_entity -ctx "{\"jid\":\"urn:uuid:83461a8c-997b-4b94-a430-05d2f9bba90c\"}"


## entity response - create response for entity
walker run create_entity_response -ctx "{\"jid\":\"urn:uuid:72a10f9a-366e-4b18-8a40-2ade63222d89\", \"response\":\"this is number\"}"
walker run update_entity_response -ctx "{\"jid\":\"urn:uuid:4e6e5e53-c1d4-45e5-ac1e-4c21203d53c1\", \"response\":\"this is new color\"}"
walker run get_entity_response -ctx "{\"jid\":\"urn:uuid:0cfc1418-9b68-4508-a108-d922dfa67710\"}"
walker run list_entity_response
walker run delete_entity_response -ctx "{\"jid\":\"urn:uuid:4e6e5e53-c1d4-45e5-ac1e-4c21203d53c1\"}"

## entity context - create context for entity
walker run create_entity_context -ctx "{\"jid\":\"urn:uuid:cb26fa85-4522-4e4c-9d72-e1e9a79552b4\", \"utterance\":\"my number is 123\", \"entity_value\":\"123\"}"
walker run update_entity_context -ctx "{\"jid\":\"urn:uuid:42152a54-cc40-41af-a7e4-8d547bbd65a4\", \"utterance\":\"my number is 1234\", \"entity_value\":\"1234\"}"
walker run get_entity_context -ctx "{\"jid\":\"urn:uuid:9adae361-74d6-482d-9a9e-22cfe261714d\"}"
walker run list_entity_context
walker run delete_entity_context -ctx "{\"jid\":\"urn:uuid:83aa1cb8-5f96-49f3-840f-f1a266b544e9\"}"


## info_item_root - 
walker run create_info_item_root -ctx "{\"jid\":\"urn:uuid:85b64aa7-beca-4420-a7c8-4828c61261fc\", \"resource\":\"numbers.json\"}"
walker run update_info_item_root -ctx "{\"jid\":\"urn:uuid:b1021771-2ea1-42e0-acd3-12bede9f1ba3\", \"resource\":\"number.json\"}"
walker run get_info_item_root -ctx "{\"jid\":\"urn:uuid:85b64aa7-beca-4420-a7c8-4828c61261fc\"}"
walker run list_info_item_root
walker run delete_info_item_root -ctx "{\"jid\":\"urn:uuid:b1021771-2ea1-42e0-acd3-12bede9f1ba3\"}"

## info_item
walker run create_state_info_item -ctx "{\"jid\":\"urn:uuid:24aafe78-fd11-482e-b7b1-932988237e2b\", \"info_item\":\"numbers\"}"
walker run update_state_info_item -ctx "{\"jid\":\"urn:uuid:4bac5486-1599-447b-8b39-994bea6539cd\", \"info_item\":\"number\"}"
walker run get_state_info_item -ctx "{\"jid\":\"urn:uuid:85b64aa7-beca-4420-a7c8-4828c61261fc\"}"
walker run list_state_info_item
walker run delete_state_info_item -ctx "{\"jid\":\"urn:uuid:da100259-392c-48a7-8c81-816206664cc2\"}"

## faq question

walker run create_faq -ctx "{\"question\":\"how ddr u\", \"answer\":\"I am good\"}"
walker run update_faq -ctx "{\"jid\":\"urn:uuid:ccd0d007-f5a9-4f49-8143-7e46085c9517\", \"question\":\"How are you?\", \"answer\":\"I am good.\"}"
walker run list_faq
walker run get_faq -ctx "{\"jid\":\"urn:uuid:82b6070e-ffca-42f4-a20a-f17f09f2106d\"}"
walker run delete_faq -ctx "{\"jid\":\"urn:uuid:82b6070e-ffca-42f4-a20a-f17f09f2106d\"}"


### tfm_ner // note for some reason tfm_ner_train only work on the server 

walker run tfm_ner_train -ctx "{\"train_file\": \"utils/data/tfm_train.json\"}"
walker run tfm_ner_infer -ctx "{\"labels\": [\"number\",\"accountname\",\"month\",\"accountNumber\"]}"
walker run tfm_ner_save_model -ctx "{\"model_path\": \"tfm_ner_model\"}"
walker run tfm_ner_load_model -ctx "{\"model_path\": \"tfm_ner_model\"}"
walker run tfm_ner_delete

## talk

walker run talk -ctx "{\"question\": \"hello\"}"
walker run talk -ctx "{\"question\": \"what time do you open\"}"
walker run talk -ctx "{\"question\": \"later\"}"
walker run talk -ctx "{\"question\": \"I would like to see my account\"}"
walker run talk -ctx "{\"question\": \"I would like to check my account\"}"
walker run talk -ctx "{\"question\": \"My number is 2315555\"}"
walker run talk -ctx "{\"question\": \"Where can I pay my bill?\"}"

