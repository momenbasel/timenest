# TimeNest - prefilled Reddit submit links

Open each link in a logged-in browser - fields are prefilled.

Post order: 1 per 10-15 min to avoid spam-filter heuristics.

## r/selfhosted

**Title** (94 chars): `TimeNest - Self-hosted Time Machine server for every Mac on your LAN (Docker, multi-arch, MIT)`

**1-click submit URL:** https://www.reddit.com/r/selfhosted/submit?selftext=true&title=TimeNest+-+Self-hosted+Time+Machine+server+for+every+Mac+on+your+LAN+%28Docker%2C+multi-arch%2C+MIT%29&text=Hey+r%2Fselfhosted%2C%0A%0AI+open-sourced+TimeNest+today.+It+packages+Samba+4.18+%2B+%60vfs_fruit%60%2C+Avahi+for+Bonjour%2C+and+a+small+FastAPI+admin+UI+into+one+%60docker+compose%60+stack+so+any+Mac+on+the+LAN+finds+the+share+in+Finder+with+the+correct+Time+Capsule+icon.+No+IP+typing%2C+no+SMB+URLs%2C+no+iCloud+upsell.%0A%0A%2A%2AWhat%27s+in+the+box%2A%2A%0A%0A-+Samba+with+per-user+Time+Machine+shares+and+%60fruit%3Atime+machine+max+size%60+quotas%0A-+Avahi+advertising+as+a+%60TimeCapsule8%2C119%60+%28three+records%3A+%60_smb%60%2C+%60_device-info%60%2C+%60_adisk%60%29%0A-+FastAPI+%2B+Jinja+%2B+htmx+admin+UI+on+%60%3A8080%60+with+live+sessions%2C+SMART+health%2C+and+Prometheus+%60%2Fmetrics%60%0A-+Multi-arch+images+for+%60linux%2Famd64%60%2C+%60linux%2Farm64%60%2C+%60linux%2Farm%2Fv7%60%0A%0A%2A%2ABenchmarks%2A%2A+%28100+GB+first+backup%29%0A%0A-+Mac+mini+M2+%2B+USB+3.2+NVMe%3A+18m+42s+at+89+MB%2Fs%0A-+Raspberry+Pi+5+%2B+USB+3+NVMe%3A+21m+05s+at+79+MB%2Fs%0A-+Raspberry+Pi+4+%2B+USB+3+SATA+SSD%3A+27m+30s+at+61+MB%2Fs%0A%0A%2A%2ALinks%2A%2A%0A%0A-+Repo%3A+https%3A%2F%2Fgithub.com%2Fmomenbasel%2Ftimenest%0A-+Architecture+deep+dive%3A+https%3A%2F%2Fgithub.com%2Fmomenbasel%2Ftimenest%2Fblob%2Fmain%2Fdocs%2FARCHITECTURE.md%0A-+Screenshots%3A+https%3A%2F%2Fgithub.com%2Fmomenbasel%2Ftimenest%23screenshots%0A%0AMIT%2C+no+telemetry%2C+entirely+offline.+Would+love+feedback+on+the+%60vfs_fruit%60+parameter+picks+-+the+ones+in+%60samba%2Fsmb.conf.template%60+are+what+survived+three+Macs+and+two+Pis+but+I+know+people+have+pushed+further.%0A

**Body preview:**
```
Hey r/selfhosted,

I open-sourced TimeNest today. It packages Samba 4.18 + `vfs_fruit`, Avahi for Bonjour, and a small FastAPI admin UI into one `docker compose` stack so any Mac on the LAN finds the share in Finder with the correct Time Capsule icon. No IP typing, no SMB URLs, no iCloud upsell.

**What's in the box**

- Samba with per-user Time Machine shares and `fruit:time machine max size` quo...
```

---

## r/homelab

**Title** (101 chars): `Replaced my Apple Time Capsule with a Raspberry Pi 5 + USB SSD running Docker - TimeNest, open source`

**1-click submit URL:** https://www.reddit.com/r/homelab/submit?selftext=true&title=Replaced+my+Apple+Time+Capsule+with+a+Raspberry+Pi+5+%2B+USB+SSD+running+Docker+-+TimeNest%2C+open+source&text=Short+writeup+on+the+homelab+project+I+just+shipped.%0A%0A%2A%2AGoal%2A%2A+-+resurrect+Time+Capsule+functionality+without+buying+used+Apple+hardware+or+paying+for+iCloud+that+does+not+back+up+the+full+disk.%0A%0A%2A%2AHardware%2A%2A+-+Raspberry+Pi+5+%288+GB%29+%2B+generic+USB+3+NVMe+enclosure+%2B+gigabit+LAN.+Cost+for+the+whole+thing%3A+about+%24180.%0A%0A%2A%2ASoftware%2A%2A+-+TimeNest%2C+a+three-container+Docker+stack%3A+Samba+%2B+%60vfs_fruit%60+for+the+actual+Time+Machine+protocol%2C+Avahi+for+Bonjour+advertisement%2C+and+a+FastAPI+admin+UI+for+users+and+quotas.%0A%0AMulti-arch+images+mean+the+same+compose+works+on+a+Mac+mini%2C+an+x86+NUC%2C+or+the+Pi.+I+use+the+Pi+in+the+homelab+and+the+Mac+mini+in+a+relative%27s+house+for+off-site+backups+over+WireGuard.%0A%0A%2A%2ABenchmark%2A%2A+on+a+100+GB+first+backup%3A+%2A%2A21+minutes%2C+79+MB%2Fs+sustained%2A%2A.%0A%0ARepo%3A+https%3A%2F%2Fgithub.com%2Fmomenbasel%2Ftimenest%0AFull+benchmarks+%2B+architecture%3A+https%3A%2F%2Fgithub.com%2Fmomenbasel%2Ftimenest%2Fblob%2Fmain%2Fdocs%2FARCHITECTURE.md%0A%0AMIT%2C+no+telemetry%2C+no+cloud+component.+Happy+to+answer+tuning+questions.%0A

**Body preview:**
```
Short writeup on the homelab project I just shipped.

**Goal** - resurrect Time Capsule functionality without buying used Apple hardware or paying for iCloud that does not back up the full disk.

**Hardware** - Raspberry Pi 5 (8 GB) + generic USB 3 NVMe enclosure + gigabit LAN. Cost for the whole thing: about $180.

**Software** - TimeNest, a three-container Docker stack: Samba + `vfs_fruit` for t...
```

---

## r/raspberry_pi

**Title** (74 chars): `I turned a Pi 5 into a Time Capsule replacement for every Mac in the house`

**1-click submit URL:** https://www.reddit.com/r/raspberry_pi/submit?selftext=true&title=I+turned+a+Pi+5+into+a+Time+Capsule+replacement+for+every+Mac+in+the+house&text=Hardware%3A+Pi+5+8+GB+%2B+USB+3+NVMe+enclosure+%2B+gigabit+Ethernet.%0A%0ASoftware%3A+%2A%2ATimeNest%2A%2A%2C+a+Docker+stack+I+just+open-sourced.+Three+containers+-+Samba+with+%60vfs_fruit%60%2C+Avahi+for+Bonjour%2C+and+a+FastAPI+admin+UI.+The+Pi+advertises+itself+as+a+%60TimeCapsule8%2C119%60+so+every+Mac+in+the+house+picks+it+up+in+Finder+and+in+Time+Machine+settings+without+typing+an+IP.%0A%0ABenchmarks+on+a+100+GB+first+backup%3A+%2A%2A21+minutes+at+79+MB%2Fs+sustained%2A%2A.+After+the+first+run%2C+incremental+backups+take+a+couple+of+minutes+and+happen+while+the+Macs+are+on+Wi-Fi.%0A%0AMulti-arch+images+cover+%60linux%2Farm64%60+%28Pi+4%2F5%29+and+%60linux%2Farm%2Fv7%60+%28Pi+2%2F3%29.+One-line+installer+handles+Docker+bootstrap%2C+prompts+for+the+drive+path%2C+writes+%60.env%60%2C+and+runs+%60docker+compose+up+-d%60.%0A%0AMIT+licensed%2C+no+telemetry%2C+no+cloud.%0A%0ARepo%3A+https%3A%2F%2Fgithub.com%2Fmomenbasel%2Ftimenest%0AInstall%3A+%60curl+-fsSL+https%3A%2F%2Fraw.githubusercontent.com%2Fmomenbasel%2Ftimenest%2Fmain%2Finstall.sh+%7C+bash%60%0A%0AIf+anybody+has+tuned+%60vfs_fruit%60+further+for+the+Pi%2C+I+want+to+hear+it.%0A

**Body preview:**
```
Hardware: Pi 5 8 GB + USB 3 NVMe enclosure + gigabit Ethernet.

Software: **TimeNest**, a Docker stack I just open-sourced. Three containers - Samba with `vfs_fruit`, Avahi for Bonjour, and a FastAPI admin UI. The Pi advertises itself as a `TimeCapsule8,119` so every Mac in the house picks it up in Finder and in Time Machine settings without typing an IP.

Benchmarks on a 100 GB first backup: **21...
```

---

## r/macapps

**Title** (98 chars): `Free, open-source Time Capsule replacement that runs on a Raspberry Pi, Mac mini, or any Linux box`

**1-click submit URL:** https://www.reddit.com/r/macapps/submit?selftext=true&title=Free%2C+open-source+Time+Capsule+replacement+that+runs+on+a+Raspberry+Pi%2C+Mac+mini%2C+or+any+Linux+box&text=If+you+miss+the+Apple+Time+Capsule+and+do+not+want+to+pay+%24119%2Fyr+for+iCloud+that+still+does+not+back+up+your+whole+disk%2C+TimeNest+might+be+for+you.%0A%0AIt+is+a+free%2C+MIT-licensed+self-hosted+Time+Machine+server.+Drop+it+on+any+Linux-capable+box+%28Mac+mini%2C+Raspberry+Pi%2C+NUC%2C+whatever+you+have%29%2C+point+it+at+an+external+drive%2C+and+every+Mac+on+the+LAN+finds+it+in+Time+Machine+settings+automatically+-+no+IP+typing%2C+no+SMB+URLs.%0A%0A%2A%2AHow+it+feels+on+the+Mac+side%2A%2A%0A%0A-+Open+System+Settings+-%3E+General+-%3E+Time+Machine+-%3E+Add+Backup+Disk.%0A-+TimeNest+shows+up+with+the+Time+Capsule+icon.%0A-+Sign+in+with+the+username%2Fpassword+you+configured+in+the+web+UI.%0A-+Done.+First+backup+is+a+full+copy%3B+everything+after+is+incremental+and+hourly.%0A%0A%2A%2AWhy+it%27s+not+just+a+raw+SMB+share%2A%2A%0A%0ATime+Machine+needs+three+Bonjour+records+%28%60_smb._tcp%60%2C+%60_device-info._tcp%60%2C+%60_adisk._tcp%60%29+advertised+from+the+same+hostname%2C+plus+the+Samba+%60vfs_fruit%60+module+with+about+a+dozen+specific+options.+Getting+those+right+is+what+makes+the+difference+between+%22the+share+appears%22+and+%22macOS+actually+accepts+it+as+a+TM+target.%22+TimeNest+handles+all+of+that.%0A%0ARepo+%2B+screenshots%3A+https%3A%2F%2Fgithub.com%2Fmomenbasel%2Ftimenest%0A

**Body preview:**
```
If you miss the Apple Time Capsule and do not want to pay $119/yr for iCloud that still does not back up your whole disk, TimeNest might be for you.

It is a free, MIT-licensed self-hosted Time Machine server. Drop it on any Linux-capable box (Mac mini, Raspberry Pi, NUC, whatever you have), point it at an external drive, and every Mac on the LAN finds it in Time Machine settings automatically - n...
```

---

## r/docker

**Title** (98 chars): `TimeNest - multi-arch Docker stack that turns any host into a network Time Machine server for Macs`

**1-click submit URL:** https://www.reddit.com/r/docker/submit?selftext=true&title=TimeNest+-+multi-arch+Docker+stack+that+turns+any+host+into+a+network+Time+Machine+server+for+Macs&text=Open-sourced+this+today.+Three-container+stack%3A%0A%0A-+%60samba%60%3A+Samba+4.18+with+%60vfs_fruit%60+for+Time+Machine+shares%0A-+%60avahi%60%3A+Bonjour+advertisement+so+macOS+clients+find+it+in+Finder%0A-+%60web%60%3A+FastAPI+%2B+Jinja+%2B+htmx+admin+UI+with+Prometheus+%60%2Fmetrics%60%0A%0ABuilt+with+buildx+for+%60linux%2Famd64%60%2C+%60linux%2Farm64%60%2C+and+%60linux%2Farm%2Fv7%60%2C+so+the+same+%60docker+compose+up+-d%60+works+on+a+Mac+mini%2C+a+Raspberry+Pi%2C+or+an+x86+NUC.%0A%0AWhat+might+be+interesting+for+this+sub%3A%0A%0A-+The+Samba+and+Avahi+containers+use+%60network_mode%3A+host%60+because+mDNS+packets+cannot+traverse+Docker+bridge+networks+-+documented+in+the+README+with+a+troubleshooting+section.%0A-+The+web+container+shells+out+via+%60docker+exec%60+to+a+helper+script+inside+the+Samba+container+for+user+management%2C+rather+than+re-implementing+Samba%27s+passdb+protocol.+Keeps+the+user-mgmt+surface+trivially+auditable.%0A-+One+healthcheck+per+service%3B+%60tini%60+as+PID+1+for+signal+handling.%0A%0ARepo%3A+https%3A%2F%2Fgithub.com%2Fmomenbasel%2Ftimenest%0ACompose+file%3A+https%3A%2F%2Fgithub.com%2Fmomenbasel%2Ftimenest%2Fblob%2Fmain%2Fdocker-compose.yml%0A%0AMIT%2C+no+telemetry.%0A

**Body preview:**
```
Open-sourced this today. Three-container stack:

- `samba`: Samba 4.18 with `vfs_fruit` for Time Machine shares
- `avahi`: Bonjour advertisement so macOS clients find it in Finder
- `web`: FastAPI + Jinja + htmx admin UI with Prometheus `/metrics`

Built with buildx for `linux/amd64`, `linux/arm64`, and `linux/arm/v7`, so the same `docker compose up -d` works on a Mac mini, a Raspberry Pi, or an x...
```

---

## r/opensource

**Title** (98 chars): `TimeNest - MIT, self-hosted Time Machine server for Macs, replaces discontinued Apple Time Capsule`

**1-click submit URL:** https://www.reddit.com/r/opensource/submit?selftext=true&title=TimeNest+-+MIT%2C+self-hosted+Time+Machine+server+for+Macs%2C+replaces+discontinued+Apple+Time+Capsule&text=Shipped+today.+TimeNest+is+a+self-hosted+Time+Machine+server+for+macOS+-+the+functional+successor+to+the+Apple+Time+Capsule%2C+which+Apple+discontinued+in+2018.%0A%0A-+Three-container+Docker+stack%3A+Samba+%2B+%60vfs_fruit%60%2C+Avahi+for+Bonjour%2C+FastAPI+admin+UI.%0A-+Runs+on+Mac+mini%2C+Raspberry+Pi%2C+or+any+%60linux%2Famd64%60+or+%60linux%2Farm64%60+host.%0A-+Per-user+Time+Machine+quotas%2C+Prometheus+metrics%2C+SMART+health.%0A-+MIT+licensed%2C+no+telemetry%2C+no+cloud+dependency.%0A-+Install+is+one+line%3A+%60curl+-fsSL+...%2Finstall.sh+%7C+bash%60.%0A%0ARepo%3A+https%3A%2F%2Fgithub.com%2Fmomenbasel%2Ftimenest%0A%0AThe+repo+also+ships+a+launch+press+kit+%28%60docs%2Fpress%2F%60%29%2C+a+security+policy%2C+and+a+short+architecture+document.+Aimed+at+being+a+reference+for+%22small+self-hosted+appliance%22+packaging+as+much+as+a+useful+tool.%0A

**Body preview:**
```
Shipped today. TimeNest is a self-hosted Time Machine server for macOS - the functional successor to the Apple Time Capsule, which Apple discontinued in 2018.

- Three-container Docker stack: Samba + `vfs_fruit`, Avahi for Bonjour, FastAPI admin UI.
- Runs on Mac mini, Raspberry Pi, or any `linux/amd64` or `linux/arm64` host.
- Per-user Time Machine quotas, Prometheus metrics, SMART health.
- MIT ...
```

---

## r/mac

**Title** (65 chars): `Self-hosted Time Machine server for Macs - TimeNest (open source)`

**1-click submit URL:** https://www.reddit.com/r/mac/submit?selftext=true&title=Self-hosted+Time+Machine+server+for+Macs+-+TimeNest+%28open+source%29&text=If+Time+Capsule+was+still+around%2C+it+would+look+something+like+this.%0A%0ATimeNest+is+a+free%2C+open-source+%28MIT%29+Time+Machine+server.+Put+it+on+any+Linux-capable+box+-+Raspberry+Pi%2C+Mac+mini%2C+old+NUC+-+point+it+at+an+external+drive%2C+and+every+Mac+on+your+LAN+finds+it+in+the+Time+Machine+picker+with+the+Time+Capsule+icon.+No+typing+IPs%2C+no+iCloud%2C+no+dangling+USB+cable.%0A%0A-+Per-user+accounts+with+size+quotas%0A-+Bonjour+auto-discovery%0A-+Dark-mode+admin+UI%0A-+Works+with+Ventura%2C+Sonoma%2C+and+Sequoia%0A%0ARepo+%2B+screenshots%3A+https%3A%2F%2Fgithub.com%2Fmomenbasel%2Ftimenest%0A

**Body preview:**
```
If Time Capsule was still around, it would look something like this.

TimeNest is a free, open-source (MIT) Time Machine server. Put it on any Linux-capable box - Raspberry Pi, Mac mini, old NUC - point it at an external drive, and every Mac on your LAN finds it in the Time Machine picker with the Time Capsule icon. No typing IPs, no iCloud, no dangling USB cable.

- Per-user accounts with size qu...
```

---

