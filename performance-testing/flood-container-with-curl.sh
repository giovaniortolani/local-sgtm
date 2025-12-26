#!/bin/bash

# Flood sGTM Container with CURL
#
# This script sends a specified number of concurrent curl requests to a local sGTM container.
# It is useful for generating load and testing the container's handling of a fixed number of requests.
#
# Usage:
#   ./flood-container-with-curl.sh [num_requests]
#
# Arguments:
#   [num_requests]  Optional. The number of requests to send. Default: 50.
#
# Examples:
#   ./flood-container-with-curl.sh
#   ./flood-container-with-curl.sh 100

REQUESTS=${1:-50}

echo "Firing $REQUESTS requests..."

for ((i=1; i<=REQUESTS; i++)); do
  echo "Firing request $i..."

  curl 'http://localhost:8888/g/collect?v=2&tid=G-ABC123&gtm=45je5bi1v896246467z877944370za200zb77944370zd77944370&_p=1764340309313&gcs=G111&gcd=13t3t3t3t5l1&npa=0&dma=0&cid=1307714608.1760043792&ecid=2122688280&ul=en-us&sr=1920x1080&lps=1&_fplc=0&ir=1&ur=BR-SP&uaa=arm&uab=64&uafvl=Chromium%3B142.0.7444.176%7CMicrosoft%2520Edge%3B142.0.3595.94%7CNot_A%2520Brand%3B99.0.0.0&uamb=0&uam=&uap=macOS&uapv=15.7.1&uaw=0&are=1&frm=0&pscdl=noapi&_eu=EAAAAAQ&sst.rnd=2042025140.1764340310&sst.etld=google.com.br&sst.tft=1764340309313&sst.lpc=3978671&sst.navt=n&sst.ude=0&sst.sw_exp=1&_s=1&tag_exp=103116026~103200004~104527907~104528500~104573694~104684208~104684211~105322303~115583767~115938466~115938468~116184927~116184929~116217636~116217638&sid=1764340309&sct=5&seg=0&dl=https%3A%2F%2Fwww.nederlandseloterij.nl%2F%3Fg%3D123123&dt=Nederlandse%20Loterij%3A%20Supporter%20van%20Kansen%20%7C%20Nederlandse%20Loterij&_tu=DAg&en=page_view&_ss=1&ep.full_page_url=https%3A%2F%2Fwww.nederlandseloterij.nl%2F%3Fgclid%3D123123&ep.cookie_level=optimaal&ep.event_id=1760044298197_17643404997032&ep.fbp=fb.1.1760043840841.908083253440121752&ep.game_brand=nederlandseloterij&ep.login_status=Niet%20ingelogd&up.cookie_level=optimaal&tfd=2135&richsstsse' \
  -H 'accept: */*' \
  -H 'accept-language: en-US,en;q=0.9,pt-BR;q=0.8,pt;q=0.7' \
  -H 'cache-control: no-cache' \
  -b '_ga=GA1.1.1307714608.1760043792; FPID=FPID2.2.UGZp%2FI9CCimRLhiVfNThoJgIkddJ7DjNjuhYawNqaAM%3D.1760043792; cookieConsent=optimaal; _gcl_au=1.1.1383095083.1760043798; _vwo_uuid_v2=DDD522EAFA1D953BFC946C4211AFB78A1|44aaa7d8195fbb0231243de325208aaf; _vwo_uuid=DDD522EAFA1D953BFC946C4211AFB78A1; _vwo_ds=3%241760043798%3A39.49500668%3A%3A; FPAU=1.1.1383095083.1760043798; rm_cid=0199cac9-b438-7847-bcd3-df5b5eb35e82; _fbp=fb.1.1760043840841.908083253440121752; _scid=d77fa612-35c9-4cec-a7b1-27e8a3070550; _vis_opt_s=2%7C; _vis_opt_test_cookie=1; nederlandseloterij_affiliate_data=none; _vis_opt_exp_2168_combi=2; ab.storage.deviceId.4fc34d19-a086-47e5-b24e-59467d365df1=g%3Adb477e7b-12de-5b5c-418e-4710ba405bd2%7Ce%3Aundefined%7Cc%3A1764264114192%7Cl%3A1764264114192; _cs_c=1; _vis_opt_exp_2124_combi=2; _vis_opt_exp_2124_goal_3=1; registration=true; _cs_id=c4ff75e2-8967-a849-9e80-61c121dca698.1764264114.1.1764264237.1764264114.1754555067.1798428114233.1.x; _uetsid=91e50960cbb511f0a79bdd023571cc69; _uetvid=91e52d70cbb511f0a4e8ab0f4fb2aec8; ab.storage.sessionId.4fc34d19-a086-47e5-b24e-59467d365df1=g%3A58cec457-cee4-8678-814a-802e678f2650%7Ce%3A1764266038526%7Cc%3A1764264114190%7Cl%3A1764264238526; tos-Staatsloterij=37; _ga_ABC123=GS2.1.s1764264114$o1$g1$t1764264243$j3$l0$h33925561; FPGCLAW=2.1.k123123$i1764264244; __cf_bm=4CeNl5vPS9rXuqpJ1WO0UyJXdqam0h5Ht6U4Odw7cVY-1764340309-1.0.1.1-Ck5t0xNoeYzHnSqvUtmL422dJjVlgg9mnmrv3ho0YFFxA59WPTvaMBrQDYZr4jZ22Kl.dOZ6pzaZBSqQ9QVnr.Oh6ofjGqYIJYZEM8u8ndk; _gcl_aw=GCL.1764340310.123123; cf_clearance=LsWeFnn9frqovMmFNWR78SER66aN_hZtgrMbz4DUSwM-1764340310-1.2.1.1-ROVGvMSzOed1s6x3m2vZ61LM_V.F.NVQ3cyqkPi4eqgmc6mf9UZLQXLLUxQCsMY4rLeAdyzbsLcE.BLe4UiWa9sy.3qJ32sd3YiZRXMTKZqzZJ9KoPpXr05Pgt9f90zEu3.ESWnusyzKGVL3ePhqlJ4Y0VtOOs31f9AiPXRCF.jCsPWS48xxPXWJGjz7TyO5iUwgFF3fnTl6VOCpRE5Fq3rRypWXRpYF5EME0ElKfhQ; _ga_3E1LPGNNMF=GS2.1.s1764340309$o5$g0$t1764340309$j60$l0$h2122688280' \
  -H 'origin: https://server-side-tagging-1005417164922.southamerica-east1.run.app' \
  -H 'pragma: no-cache' \
  -H 'referer: https://server-side-tagging-1005417164922.southamerica-east1.run.app/' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0' \
  -s -o /dev/null &

done

wait  # final wait to ensure all are complete