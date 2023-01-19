import re
from jaseci.actions.live_actions import jaseci_action  # step 1

# s = "can you show me my balance. the number is [2311-1](number)"
# a = s[s.find("(")+1:s.find(")")]
# b = s[s.find("[")+1:s.find("]")]
# print(a)
# print(b)


# s = [
#     "My phone number is [231-5555](number)",
#     "[231-5555](number) is my number",
#     "the number i used was [231-5555](number)"
# ]

@jaseci_action(act_group=["local"], allow_remote=True)
def entity_value(utterance:str, utterance_list:list):
    lis = []
    if utterance_list:
        for utterance in utterance_list:
            n = utterance[utterance.find("(")+1:utterance.find(")")]
            m = utterance[utterance.find("[")+1:utterance.find("]")]

            data = {"value": m, "entity": n, "utterance": utterance}
            lis.append(data)
    else:
        n = utterance[utterance.find("(")+1:utterance.find(")")]
        m = utterance[utterance.find("[")+1:utterance.find("]")]
        
        
        data = {"value": m, "entity": n, "utterance": utterance}
        lis.append(data)

    # return {"value": m.group(1), "entity": n.group(1)}
    return lis

# m = entity_value(None, s)
# # m = entity_value(s, None)
# print(m)


# test_str = "Gfg is best for geeks and CS"
 
# # printing original string
# print("The original string is : " + str(test_str))
 
# # initializing substrings
# sub1 = "is"
# sub2 = "and"
 
# # getting index of substrings
# idx1 = test_str.index(sub1)
# idx2 = test_str.index(sub2)
 
# # length of substring 1 is added to
# # get string from next character
# res = test_str[idx1 + len(sub1) + 1: idx2]
 
# # printing result
# print("The extracted string : " + res)


# test_str = "Gfg is best for geeks and CS"
 
# # printing original string
# print("The original string is : " + str(test_str))
 
# # initializing substrings
# sub1 = "is"
# sub2 = "and"
 
# test_str=test_str.replace(sub1,"*")
# test_str=test_str.replace(sub2,"*")
# re=test_str.split("*")
# res=re[1]
 
# # printing result
# print("The extracted string : " + res)



# import re
# # test_str = "Gfg is best for geeks and CS"
# test_str= "My phone number is [231-5555](number)",
# # printing original string
# print("The original string is : " +
#       str(test_str))
 
# # initializing substrings
# sub1 = "["
# sub2 = "]"
 
# s=str(re.escape(sub1))
 
# e=str(re.escape(sub2))
 
# # printing result
# res=re.findall(s+"(.*)"+e,test_str)[0]
 
# print("The extracted string : " + res)