{ config, lib, pkgs, ... }:

{
  home.shellAliases = {
    k = "kubectl";
    kk = "kubectl kustomize";
    kex = "kubectl exec -i -t";
    klo = "kubectl logs -f";
    klop = "kubectl logs -f -p";
    kpf = "kubectl port-forward";
    kg = "kubectl get";
    kd = "kubectl describe";
    krm = "kubectl delete";
    kgpo = "kubectl get pods";
    kdpo = "kubectl describe pods";
    krmpo = "kubectl delete pods";
    kgdep = "kubectl get deployment";
    kddep = "kubectl describe deployment";
    krmdep = "kubectl delete deployment";
    kgsts = "kubectl get statefulset";
    kdsts = "kubectl describe statefulset";
    krmsts = "kubectl delete statefulset";
    kgsvc = "kubectl get service";
    kdsvc = "kubectl describe service";
    krmsvc = "kubectl delete service";
    kging = "kubectl get ingress";
    kding = "kubectl describe ingress";
    krming = "kubectl delete ingress";
    kgcm = "kubectl get configmap";
    kdcm = "kubectl describe configmap";
    krmcm = "kubectl delete configmap";
    kgsec = "kubectl get secret";
    kdsec = "kubectl describe secret";
    krmsec = "kubectl delete secret";
    kgno = "kubectl get nodes";
    kdno = "kubectl describe nodes";
    kgns = "kubectl get namespaces";
    kdns = "kubectl describe namespaces";
    krmns = "kubectl delete namespaces";
    kgoyaml = "kubectl get -o=yaml";
    kgpooyaml = "kubectl get pods -o=yaml";
    kgdepoyaml = "kubectl get deployment -o=yaml";
    kgstsoyaml = "kubectl get statefulset -o=yaml";
    kgsvcoyaml = "kubectl get service -o=yaml";
    kgingoyaml = "kubectl get ingress -o=yaml";
    kgcmoyaml = "kubectl get configmap -o=yaml";
    kgsecoyaml = "kubectl get secret -o=yaml";
    kgnooyaml = "kubectl get nodes -o=yaml";
    kgnsoyaml = "kubectl get namespaces -o=yaml";
    kgowide = "kubectl get -o=wide";
    kgpoowide = "kubectl get pods -o=wide";
    kgdepowide = "kubectl get deployment -o=wide";
    kgstsowide = "kubectl get statefulset -o=wide";
    kgsvcowide = "kubectl get service -o=wide";
    kgingowide = "kubectl get ingress -o=wide";
    kgcmowide = "kubectl get configmap -o=wide";
    kgsecowide = "kubectl get secret -o=wide";
    kgnoowide = "kubectl get nodes -o=wide";
    kgnsowide = "kubectl get namespaces -o=wide";
    kgojson = "kubectl get -o=json";
    kgpoojson = "kubectl get pods -o=json";
    kgdepojson = "kubectl get deployment -o=json";
    kgstsojson = "kubectl get statefulset -o=json";
    kgsvcojson = "kubectl get service -o=json";
    kgingojson = "kubectl get ingress -o=json";
    kgcmojson = "kubectl get configmap -o=json";
    kgsecojson = "kubectl get secret -o=json";
    kgnoojson = "kubectl get nodes -o=json";
    kgnsojson = "kubectl get namespaces -o=json";
    kgall = "kubectl get --all-namespaces";
    kdall = "kubectl describe --all-namespaces";
    kgpoall = "kubectl get pods --all-namespaces";
    kdpoall = "kubectl describe pods --all-namespaces";
    kgdepall = "kubectl get deployment --all-namespaces";
    kddepall = "kubectl describe deployment --all-namespaces";
    kgstsall = "kubectl get statefulset --all-namespaces";
    kdstsall = "kubectl describe statefulset --all-namespaces";
    kgsvcall = "kubectl get service --all-namespaces";
    kdsvcall = "kubectl describe service --all-namespaces";
    kgingall = "kubectl get ingress --all-namespaces";
    kdingall = "kubectl describe ingress --all-namespaces";
    kgcmall = "kubectl get configmap --all-namespaces";
    kdcmall = "kubectl describe configmap --all-namespaces";
    kgsecall = "kubectl get secret --all-namespaces";
    kdsecall = "kubectl describe secret --all-namespaces";
    kgnsall = "kubectl get namespaces --all-namespaces";
    kdnsall = "kubectl describe namespaces --all-namespaces";
    kgsl = "kubectl get --show-labels";
    kgposl = "kubectl get pods --show-labels";
    kgdepsl = "kubectl get deployment --show-labels";
    kgstssl = "kubectl get statefulset --show-labels";
    kgsvcsl = "kubectl get service --show-labels";
    kgingsl = "kubectl get ingress --show-labels";
    kgcmsl = "kubectl get configmap --show-labels";
    kgsecsl = "kubectl get secret --show-labels";
    kgnosl = "kubectl get nodes --show-labels";
    kgnssl = "kubectl get namespaces --show-labels";
    krmall = "kubectl delete --all";
    krmpoall = "kubectl delete pods --all";
    krmdepall = "kubectl delete deployment --all";
    krmstsall = "kubectl delete statefulset --all";
    krmsvcall = "kubectl delete service --all";
    krmingall = "kubectl delete ingress --all";
    krmcmall = "kubectl delete configmap --all";
    krmsecall = "kubectl delete secret --all";
    krmnsall = "kubectl delete namespaces --all";
    kgw = "kubectl get --watch";
    kgpow = "kubectl get pods --watch";
    kgdepw = "kubectl get deployment --watch";
    kgstsw = "kubectl get statefulset --watch";
    kgsvcw = "kubectl get service --watch";
    kgingw = "kubectl get ingress --watch";
    kgcmw = "kubectl get configmap --watch";
    kgsecw = "kubectl get secret --watch";
    kgnow = "kubectl get nodes --watch";
    kgnsw = "kubectl get namespaces --watch";
    kgoyamlall = "kubectl get -o=yaml --all-namespaces";
    kgpooyamlall = "kubectl get pods -o=yaml --all-namespaces";
    kgdepoyamlall = "kubectl get deployment -o=yaml --all-namespaces";
    kgstsoyamlall = "kubectl get statefulset -o=yaml --all-namespaces";
    kgsvcoyamlall = "kubectl get service -o=yaml --all-namespaces";
    kgingoyamlall = "kubectl get ingress -o=yaml --all-namespaces";
    kgcmoyamlall = "kubectl get configmap -o=yaml --all-namespaces";
    kgsecoyamlall = "kubectl get secret -o=yaml --all-namespaces";
    kgnsoyamlall = "kubectl get namespaces -o=yaml --all-namespaces";
    kgalloyaml = "kubectl get --all-namespaces -o=yaml";
    kgpoalloyaml = "kubectl get pods --all-namespaces -o=yaml";
    kgdepalloyaml = "kubectl get deployment --all-namespaces -o=yaml";
    kgstsalloyaml = "kubectl get statefulset --all-namespaces -o=yaml";
    kgsvcalloyaml = "kubectl get service --all-namespaces -o=yaml";
    kgingalloyaml = "kubectl get ingress --all-namespaces -o=yaml";
    kgcmalloyaml = "kubectl get configmap --all-namespaces -o=yaml";
    kgsecalloyaml = "kubectl get secret --all-namespaces -o=yaml";
    kgnsalloyaml = "kubectl get namespaces --all-namespaces -o=yaml";
    kgowideall = "kubectl get -o=wide --all-namespaces";
    kgpoowideall = "kubectl get pods -o=wide --all-namespaces";
    kgdepowideall = "kubectl get deployment -o=wide --all-namespaces";
    kgstsowideall = "kubectl get statefulset -o=wide --all-namespaces";
    kgsvcowideall = "kubectl get service -o=wide --all-namespaces";
    kgingowideall = "kubectl get ingress -o=wide --all-namespaces";
    kgcmowideall = "kubectl get configmap -o=wide --all-namespaces";
    kgsecowideall = "kubectl get secret -o=wide --all-namespaces";
    kgnsowideall = "kubectl get namespaces -o=wide --all-namespaces";
    kgallowide = "kubectl get --all-namespaces -o=wide";
    kgpoallowide = "kubectl get pods --all-namespaces -o=wide";
    kgdepallowide = "kubectl get deployment --all-namespaces -o=wide";
    kgstsallowide = "kubectl get statefulset --all-namespaces -o=wide";
    kgsvcallowide = "kubectl get service --all-namespaces -o=wide";
    kgingallowide = "kubectl get ingress --all-namespaces -o=wide";
    kgcmallowide = "kubectl get configmap --all-namespaces -o=wide";
    kgsecallowide = "kubectl get secret --all-namespaces -o=wide";
    kgnsallowide = "kubectl get namespaces --all-namespaces -o=wide";
    kgowidesl = "kubectl get -o=wide --show-labels";
    kgpoowidesl = "kubectl get pods -o=wide --show-labels";
    kgdepowidesl = "kubectl get deployment -o=wide --show-labels";
    kgstsowidesl = "kubectl get statefulset -o=wide --show-labels";
    kgsvcowidesl = "kubectl get service -o=wide --show-labels";
    kgingowidesl = "kubectl get ingress -o=wide --show-labels";
    kgcmowidesl = "kubectl get configmap -o=wide --show-labels";
    kgsecowidesl = "kubectl get secret -o=wide --show-labels";
    kgnoowidesl = "kubectl get nodes -o=wide --show-labels";
    kgnsowidesl = "kubectl get namespaces -o=wide --show-labels";
    kgslowide = "kubectl get --show-labels -o=wide";
    kgposlowide = "kubectl get pods --show-labels -o=wide";
    kgdepslowide = "kubectl get deployment --show-labels -o=wide";
    kgstsslowide = "kubectl get statefulset --show-labels -o=wide";
    kgsvcslowide = "kubectl get service --show-labels -o=wide";
    kgingslowide = "kubectl get ingress --show-labels -o=wide";
    kgcmslowide = "kubectl get configmap --show-labels -o=wide";
    kgsecslowide = "kubectl get secret --show-labels -o=wide";
    kgnoslowide = "kubectl get nodes --show-labels -o=wide";
    kgnsslowide = "kubectl get namespaces --show-labels -o=wide";
    kgojsonall = "kubectl get -o=json --all-namespaces";
    kgpoojsonall = "kubectl get pods -o=json --all-namespaces";
    kgdepojsonall = "kubectl get deployment -o=json --all-namespaces";
    kgstsojsonall = "kubectl get statefulset -o=json --all-namespaces";
    kgsvcojsonall = "kubectl get service -o=json --all-namespaces";
    kgingojsonall = "kubectl get ingress -o=json --all-namespaces";
    kgcmojsonall = "kubectl get configmap -o=json --all-namespaces";
    kgsecojsonall = "kubectl get secret -o=json --all-namespaces";
    kgnsojsonall = "kubectl get namespaces -o=json --all-namespaces";
    kgallojson = "kubectl get --all-namespaces -o=json";
    kgpoallojson = "kubectl get pods --all-namespaces -o=json";
    kgdepallojson = "kubectl get deployment --all-namespaces -o=json";
    kgstsallojson = "kubectl get statefulset --all-namespaces -o=json";
    kgsvcallojson = "kubectl get service --all-namespaces -o=json";
    kgingallojson = "kubectl get ingress --all-namespaces -o=json";
    kgcmallojson = "kubectl get configmap --all-namespaces -o=json";
    kgsecallojson = "kubectl get secret --all-namespaces -o=json";
    kgnsallojson = "kubectl get namespaces --all-namespaces -o=json";
    kgallsl = "kubectl get --all-namespaces --show-labels";
    kgpoallsl = "kubectl get pods --all-namespaces --show-labels";
    kgdepallsl = "kubectl get deployment --all-namespaces --show-labels";
    kgstsallsl = "kubectl get statefulset --all-namespaces --show-labels";
    kgsvcallsl = "kubectl get service --all-namespaces --show-labels";
    kgingallsl = "kubectl get ingress --all-namespaces --show-labels";
    kgcmallsl = "kubectl get configmap --all-namespaces --show-labels";
    kgsecallsl = "kubectl get secret --all-namespaces --show-labels";
    kgnsallsl = "kubectl get namespaces --all-namespaces --show-labels";
    kgslall = "kubectl get --show-labels --all-namespaces";
    kgposlall = "kubectl get pods --show-labels --all-namespaces";
    kgdepslall = "kubectl get deployment --show-labels --all-namespaces";
    kgstsslall = "kubectl get statefulset --show-labels --all-namespaces";
    kgsvcslall = "kubectl get service --show-labels --all-namespaces";
    kgingslall = "kubectl get ingress --show-labels --all-namespaces";
    kgcmslall = "kubectl get configmap --show-labels --all-namespaces";
    kgsecslall = "kubectl get secret --show-labels --all-namespaces";
    kgnsslall = "kubectl get namespaces --show-labels --all-namespaces";
    kgallw = "kubectl get --all-namespaces --watch";
    kgpoallw = "kubectl get pods --all-namespaces --watch";
    kgdepallw = "kubectl get deployment --all-namespaces --watch";
    kgstsallw = "kubectl get statefulset --all-namespaces --watch";
    kgsvcallw = "kubectl get service --all-namespaces --watch";
    kgingallw = "kubectl get ingress --all-namespaces --watch";
    kgcmallw = "kubectl get configmap --all-namespaces --watch";
    kgsecallw = "kubectl get secret --all-namespaces --watch";
    kgnsallw = "kubectl get namespaces --all-namespaces --watch";
    kgwall = "kubectl get --watch --all-namespaces";
    kgpowall = "kubectl get pods --watch --all-namespaces";
    kgdepwall = "kubectl get deployment --watch --all-namespaces";
    kgstswall = "kubectl get statefulset --watch --all-namespaces";
    kgsvcwall = "kubectl get service --watch --all-namespaces";
    kgingwall = "kubectl get ingress --watch --all-namespaces";
    kgcmwall = "kubectl get configmap --watch --all-namespaces";
    kgsecwall = "kubectl get secret --watch --all-namespaces";
    kgnswall = "kubectl get namespaces --watch --all-namespaces";
    kgslw = "kubectl get --show-labels --watch";
    kgposlw = "kubectl get pods --show-labels --watch";
    kgdepslw = "kubectl get deployment --show-labels --watch";
    kgstsslw = "kubectl get statefulset --show-labels --watch";
    kgsvcslw = "kubectl get service --show-labels --watch";
    kgingslw = "kubectl get ingress --show-labels --watch";
    kgcmslw = "kubectl get configmap --show-labels --watch";
    kgsecslw = "kubectl get secret --show-labels --watch";
    kgnoslw = "kubectl get nodes --show-labels --watch";
    kgnsslw = "kubectl get namespaces --show-labels --watch";
    kgwsl = "kubectl get --watch --show-labels";
    kgpowsl = "kubectl get pods --watch --show-labels";
    kgdepwsl = "kubectl get deployment --watch --show-labels";
    kgstswsl = "kubectl get statefulset --watch --show-labels";
    kgsvcwsl = "kubectl get service --watch --show-labels";
    kgingwsl = "kubectl get ingress --watch --show-labels";
    kgcmwsl = "kubectl get configmap --watch --show-labels";
    kgsecwsl = "kubectl get secret --watch --show-labels";
    kgnowsl = "kubectl get nodes --watch --show-labels";
    kgnswsl = "kubectl get namespaces --watch --show-labels";
    kgowideallsl = "kubectl get -o=wide --all-namespaces --show-labels";
    kgpoowideallsl = "kubectl get pods -o=wide --all-namespaces --show-labels";
    kgdepowideallsl = "kubectl get deployment -o=wide --all-namespaces --show-labels";
    kgstsowideallsl = "kubectl get statefulset -o=wide --all-namespaces --show-labels";
    kgsvcowideallsl = "kubectl get service -o=wide --all-namespaces --show-labels";
    kgingowideallsl = "kubectl get ingress -o=wide --all-namespaces --show-labels";
    kgcmowideallsl = "kubectl get configmap -o=wide --all-namespaces --show-labels";
    kgsecowideallsl = "kubectl get secret -o=wide --all-namespaces --show-labels";
    kgnsowideallsl = "kubectl get namespaces -o=wide --all-namespaces --show-labels";
    kgowideslall = "kubectl get -o=wide --show-labels --all-namespaces";
    kgpoowideslall = "kubectl get pods -o=wide --show-labels --all-namespaces";
    kgdepowideslall = "kubectl get deployment -o=wide --show-labels --all-namespaces";
    kgstsowideslall = "kubectl get statefulset -o=wide --show-labels --all-namespaces";
    kgsvcowideslall = "kubectl get service -o=wide --show-labels --all-namespaces";
    kgingowideslall = "kubectl get ingress -o=wide --show-labels --all-namespaces";
    kgcmowideslall = "kubectl get configmap -o=wide --show-labels --all-namespaces";
    kgsecowideslall = "kubectl get secret -o=wide --show-labels --all-namespaces";
    kgnsowideslall = "kubectl get namespaces -o=wide --show-labels --all-namespaces";
    kgallowidesl = "kubectl get --all-namespaces -o=wide --show-labels";
    kgpoallowidesl = "kubectl get pods --all-namespaces -o=wide --show-labels";
    kgdepallowidesl = "kubectl get deployment --all-namespaces -o=wide --show-labels";
    kgstsallowidesl = "kubectl get statefulset --all-namespaces -o=wide --show-labels";
    kgsvcallowidesl = "kubectl get service --all-namespaces -o=wide --show-labels";
    kgingallowidesl = "kubectl get ingress --all-namespaces -o=wide --show-labels";
    kgcmallowidesl = "kubectl get configmap --all-namespaces -o=wide --show-labels";
    kgsecallowidesl = "kubectl get secret --all-namespaces -o=wide --show-labels";
    kgnsallowidesl = "kubectl get namespaces --all-namespaces -o=wide --show-labels";
    kgallslowide = "kubectl get --all-namespaces --show-labels -o=wide";
    kgpoallslowide = "kubectl get pods --all-namespaces --show-labels -o=wide";
    kgdepallslowide = "kubectl get deployment --all-namespaces --show-labels -o=wide";
    kgstsallslowide = "kubectl get statefulset --all-namespaces --show-labels -o=wide";
    kgsvcallslowide = "kubectl get service --all-namespaces --show-labels -o=wide";
    kgingallslowide = "kubectl get ingress --all-namespaces --show-labels -o=wide";
    kgcmallslowide = "kubectl get configmap --all-namespaces --show-labels -o=wide";
    kgsecallslowide = "kubectl get secret --all-namespaces --show-labels -o=wide";
    kgnsallslowide = "kubectl get namespaces --all-namespaces --show-labels -o=wide";
    kgslowideall = "kubectl get --show-labels -o=wide --all-namespaces";
    kgposlowideall = "kubectl get pods --show-labels -o=wide --all-namespaces";
    kgdepslowideall = "kubectl get deployment --show-labels -o=wide --all-namespaces";
    kgstsslowideall = "kubectl get statefulset --show-labels -o=wide --all-namespaces";
    kgsvcslowideall = "kubectl get service --show-labels -o=wide --all-namespaces";
    kgingslowideall = "kubectl get ingress --show-labels -o=wide --all-namespaces";
    kgcmslowideall = "kubectl get configmap --show-labels -o=wide --all-namespaces";
    kgsecslowideall = "kubectl get secret --show-labels -o=wide --all-namespaces";
    kgnsslowideall = "kubectl get namespaces --show-labels -o=wide --all-namespaces";
    kgslallowide = "kubectl get --show-labels --all-namespaces -o=wide";
    kgposlallowide = "kubectl get pods --show-labels --all-namespaces -o=wide";
    kgdepslallowide = "kubectl get deployment --show-labels --all-namespaces -o=wide";
    kgstsslallowide = "kubectl get statefulset --show-labels --all-namespaces -o=wide";
    kgsvcslallowide = "kubectl get service --show-labels --all-namespaces -o=wide";
    kgingslallowide = "kubectl get ingress --show-labels --all-namespaces -o=wide";
    kgcmslallowide = "kubectl get configmap --show-labels --all-namespaces -o=wide";
    kgsecslallowide = "kubectl get secret --show-labels --all-namespaces -o=wide";
    kgnsslallowide = "kubectl get namespaces --show-labels --all-namespaces -o=wide";
    kgallslw = "kubectl get --all-namespaces --show-labels --watch";
    kgpoallslw = "kubectl get pods --all-namespaces --show-labels --watch";
    kgdepallslw = "kubectl get deployment --all-namespaces --show-labels --watch";
    kgstsallslw = "kubectl get statefulset --all-namespaces --show-labels --watch";
    kgsvcallslw = "kubectl get service --all-namespaces --show-labels --watch";
    kgingallslw = "kubectl get ingress --all-namespaces --show-labels --watch";
    kgcmallslw = "kubectl get configmap --all-namespaces --show-labels --watch";
    kgsecallslw = "kubectl get secret --all-namespaces --show-labels --watch";
    kgnsallslw = "kubectl get namespaces --all-namespaces --show-labels --watch";
    kgallwsl = "kubectl get --all-namespaces --watch --show-labels";
    kgpoallwsl = "kubectl get pods --all-namespaces --watch --show-labels";
    kgdepallwsl = "kubectl get deployment --all-namespaces --watch --show-labels";
    kgstsallwsl = "kubectl get statefulset --all-namespaces --watch --show-labels";
    kgsvcallwsl = "kubectl get service --all-namespaces --watch --show-labels";
    kgingallwsl = "kubectl get ingress --all-namespaces --watch --show-labels";
    kgcmallwsl = "kubectl get configmap --all-namespaces --watch --show-labels";
    kgsecallwsl = "kubectl get secret --all-namespaces --watch --show-labels";
    kgnsallwsl = "kubectl get namespaces --all-namespaces --watch --show-labels";
    kgslallw = "kubectl get --show-labels --all-namespaces --watch";
    kgposlallw = "kubectl get pods --show-labels --all-namespaces --watch";
    kgdepslallw = "kubectl get deployment --show-labels --all-namespaces --watch";
    kgstsslallw = "kubectl get statefulset --show-labels --all-namespaces --watch";
    kgsvcslallw = "kubectl get service --show-labels --all-namespaces --watch";
    kgingslallw = "kubectl get ingress --show-labels --all-namespaces --watch";
    kgcmslallw = "kubectl get configmap --show-labels --all-namespaces --watch";
    kgsecslallw = "kubectl get secret --show-labels --all-namespaces --watch";
    kgnsslallw = "kubectl get namespaces --show-labels --all-namespaces --watch";
    kgslwall = "kubectl get --show-labels --watch --all-namespaces";
    kgposlwall = "kubectl get pods --show-labels --watch --all-namespaces";
    kgdepslwall = "kubectl get deployment --show-labels --watch --all-namespaces";
    kgstsslwall = "kubectl get statefulset --show-labels --watch --all-namespaces";
    kgsvcslwall = "kubectl get service --show-labels --watch --all-namespaces";
    kgingslwall = "kubectl get ingress --show-labels --watch --all-namespaces";
    kgcmslwall = "kubectl get configmap --show-labels --watch --all-namespaces";
    kgsecslwall = "kubectl get secret --show-labels --watch --all-namespaces";
    kgnsslwall = "kubectl get namespaces --show-labels --watch --all-namespaces";
    kgwallsl = "kubectl get --watch --all-namespaces --show-labels";
    kgpowallsl = "kubectl get pods --watch --all-namespaces --show-labels";
    kgdepwallsl = "kubectl get deployment --watch --all-namespaces --show-labels";
    kgstswallsl = "kubectl get statefulset --watch --all-namespaces --show-labels";
    kgsvcwallsl = "kubectl get service --watch --all-namespaces --show-labels";
    kgingwallsl = "kubectl get ingress --watch --all-namespaces --show-labels";
    kgcmwallsl = "kubectl get configmap --watch --all-namespaces --show-labels";
    kgsecwallsl = "kubectl get secret --watch --all-namespaces --show-labels";
    kgnswallsl = "kubectl get namespaces --watch --all-namespaces --show-labels";
    kgwslall = "kubectl get --watch --show-labels --all-namespaces";
    kgpowslall = "kubectl get pods --watch --show-labels --all-namespaces";
    kgdepwslall = "kubectl get deployment --watch --show-labels --all-namespaces";
    kgstswslall = "kubectl get statefulset --watch --show-labels --all-namespaces";
    kgsvcwslall = "kubectl get service --watch --show-labels --all-namespaces";
    kgingwslall = "kubectl get ingress --watch --show-labels --all-namespaces";
    kgcmwslall = "kubectl get configmap --watch --show-labels --all-namespaces";
    kgsecwslall = "kubectl get secret --watch --show-labels --all-namespaces";
    kgnswslall = "kubectl get namespaces --watch --show-labels --all-namespaces";
    kgf = "kubectl get --recursive -f";
    kdf = "kubectl describe --recursive -f";
    krmf = "kubectl delete --recursive -f";
    kgoyamlf = "kubectl get -o=yaml --recursive -f";
    kgowidef = "kubectl get -o=wide --recursive -f";
    kgojsonf = "kubectl get -o=json --recursive -f";
    kgslf = "kubectl get --show-labels --recursive -f";
    kgwf = "kubectl get --watch --recursive -f";
    kgowideslf = "kubectl get -o=wide --show-labels --recursive -f";
    kgslowidef = "kubectl get --show-labels -o=wide --recursive -f";
    kgslwf = "kubectl get --show-labels --watch --recursive -f";
    kgwslf = "kubectl get --watch --show-labels --recursive -f";
    kgl = "kubectl get -l";
    kdl = "kubectl describe -l";
    krml = "kubectl delete -l";
    kgpol = "kubectl get pods -l";
    kdpol = "kubectl describe pods -l";
    krmpol = "kubectl delete pods -l";
    kgdepl = "kubectl get deployment -l";
    kddepl = "kubectl describe deployment -l";
    krmdepl = "kubectl delete deployment -l";
    kgstsl = "kubectl get statefulset -l";
    kdstsl = "kubectl describe statefulset -l";
    krmstsl = "kubectl delete statefulset -l";
    kgsvcl = "kubectl get service -l";
    kdsvcl = "kubectl describe service -l";
    krmsvcl = "kubectl delete service -l";
    kgingl = "kubectl get ingress -l";
    kdingl = "kubectl describe ingress -l";
    krmingl = "kubectl delete ingress -l";
    kgcml = "kubectl get configmap -l";
    kdcml = "kubectl describe configmap -l";
    krmcml = "kubectl delete configmap -l";
    kgsecl = "kubectl get secret -l";
    kdsecl = "kubectl describe secret -l";
    krmsecl = "kubectl delete secret -l";
    kgnol = "kubectl get nodes -l";
    kdnol = "kubectl describe nodes -l";
    kgnsl = "kubectl get namespaces -l";
    kdnsl = "kubectl describe namespaces -l";
    krmnsl = "kubectl delete namespaces -l";
    kgoyamll = "kubectl get -o=yaml -l";
    kgpooyamll = "kubectl get pods -o=yaml -l";
    kgdepoyamll = "kubectl get deployment -o=yaml -l";
    kgstsoyamll = "kubectl get statefulset -o=yaml -l";
    kgsvcoyamll = "kubectl get service -o=yaml -l";
    kgingoyamll = "kubectl get ingress -o=yaml -l";
    kgcmoyamll = "kubectl get configmap -o=yaml -l";
    kgsecoyamll = "kubectl get secret -o=yaml -l";
    kgnooyamll = "kubectl get nodes -o=yaml -l";
    kgnsoyamll = "kubectl get namespaces -o=yaml -l";
    kgowidel = "kubectl get -o=wide -l";
    kgpoowidel = "kubectl get pods -o=wide -l";
    kgdepowidel = "kubectl get deployment -o=wide -l";
    kgstsowidel = "kubectl get statefulset -o=wide -l";
    kgsvcowidel = "kubectl get service -o=wide -l";
    kgingowidel = "kubectl get ingress -o=wide -l";
    kgcmowidel = "kubectl get configmap -o=wide -l";
    kgsecowidel = "kubectl get secret -o=wide -l";
    kgnoowidel = "kubectl get nodes -o=wide -l";
    kgnsowidel = "kubectl get namespaces -o=wide -l";
    kgojsonl = "kubectl get -o=json -l";
    kgpoojsonl = "kubectl get pods -o=json -l";
    kgdepojsonl = "kubectl get deployment -o=json -l";
    kgstsojsonl = "kubectl get statefulset -o=json -l";
    kgsvcojsonl = "kubectl get service -o=json -l";
    kgingojsonl = "kubectl get ingress -o=json -l";
    kgcmojsonl = "kubectl get configmap -o=json -l";
    kgsecojsonl = "kubectl get secret -o=json -l";
    kgnoojsonl = "kubectl get nodes -o=json -l";
    kgnsojsonl = "kubectl get namespaces -o=json -l";
    kgsll = "kubectl get --show-labels -l";
    kgposll = "kubectl get pods --show-labels -l";
    kgdepsll = "kubectl get deployment --show-labels -l";
    kgstssll = "kubectl get statefulset --show-labels -l";
    kgsvcsll = "kubectl get service --show-labels -l";
    kgingsll = "kubectl get ingress --show-labels -l";
    kgcmsll = "kubectl get configmap --show-labels -l";
    kgsecsll = "kubectl get secret --show-labels -l";
    kgnosll = "kubectl get nodes --show-labels -l";
    kgnssll = "kubectl get namespaces --show-labels -l";
    kgwl = "kubectl get --watch -l";
    kgpowl = "kubectl get pods --watch -l";
    kgdepwl = "kubectl get deployment --watch -l";
    kgstswl = "kubectl get statefulset --watch -l";
    kgsvcwl = "kubectl get service --watch -l";
    kgingwl = "kubectl get ingress --watch -l";
    kgcmwl = "kubectl get configmap --watch -l";
    kgsecwl = "kubectl get secret --watch -l";
    kgnowl = "kubectl get nodes --watch -l";
    kgnswl = "kubectl get namespaces --watch -l";
    kgowidesll = "kubectl get -o=wide --show-labels -l";
    kgpoowidesll = "kubectl get pods -o=wide --show-labels -l";
    kgdepowidesll = "kubectl get deployment -o=wide --show-labels -l";
    kgstsowidesll = "kubectl get statefulset -o=wide --show-labels -l";
    kgsvcowidesll = "kubectl get service -o=wide --show-labels -l";
    kgingowidesll = "kubectl get ingress -o=wide --show-labels -l";
    kgcmowidesll = "kubectl get configmap -o=wide --show-labels -l";
    kgsecowidesll = "kubectl get secret -o=wide --show-labels -l";
    kgnoowidesll = "kubectl get nodes -o=wide --show-labels -l";
    kgnsowidesll = "kubectl get namespaces -o=wide --show-labels -l";
    kgslowidel = "kubectl get --show-labels -o=wide -l";
    kgposlowidel = "kubectl get pods --show-labels -o=wide -l";
    kgdepslowidel = "kubectl get deployment --show-labels -o=wide -l";
    kgstsslowidel = "kubectl get statefulset --show-labels -o=wide -l";
    kgsvcslowidel = "kubectl get service --show-labels -o=wide -l";
    kgingslowidel = "kubectl get ingress --show-labels -o=wide -l";
    kgcmslowidel = "kubectl get configmap --show-labels -o=wide -l";
    kgsecslowidel = "kubectl get secret --show-labels -o=wide -l";
    kgnoslowidel = "kubectl get nodes --show-labels -o=wide -l";
    kgnsslowidel = "kubectl get namespaces --show-labels -o=wide -l";
    kgslwl = "kubectl get --show-labels --watch -l";
    kgposlwl = "kubectl get pods --show-labels --watch -l";
    kgdepslwl = "kubectl get deployment --show-labels --watch -l";
    kgstsslwl = "kubectl get statefulset --show-labels --watch -l";
    kgsvcslwl = "kubectl get service --show-labels --watch -l";
    kgingslwl = "kubectl get ingress --show-labels --watch -l";
    kgcmslwl = "kubectl get configmap --show-labels --watch -l";
    kgsecslwl = "kubectl get secret --show-labels --watch -l";
    kgnoslwl = "kubectl get nodes --show-labels --watch -l";
    kgnsslwl = "kubectl get namespaces --show-labels --watch -l";
    kgwsll = "kubectl get --watch --show-labels -l";
    kgpowsll = "kubectl get pods --watch --show-labels -l";
    kgdepwsll = "kubectl get deployment --watch --show-labels -l";
    kgstswsll = "kubectl get statefulset --watch --show-labels -l";
    kgsvcwsll = "kubectl get service --watch --show-labels -l";
    kgingwsll = "kubectl get ingress --watch --show-labels -l";
    kgcmwsll = "kubectl get configmap --watch --show-labels -l";
    kgsecwsll = "kubectl get secret --watch --show-labels -l";
    kgnowsll = "kubectl get nodes --watch --show-labels -l";
    kgnswsll = "kubectl get namespaces --watch --show-labels -l";
  };
}
