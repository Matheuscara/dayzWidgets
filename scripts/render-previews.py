#!/usr/bin/env python3
"""Renderiza as ilustrações do README com dados fictícios, Chromium e ImageMagick."""
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'docs/previews'

def icon(name, size=22):
    paths = {
        'folder': '<path d="M3 7h7l2 2h9v11H3z"/><path d="M3 7V4h7l2 3"/>',
        'terminal': '<path d="m5 7 5 5-5 5m8 0h6"/>',
        'globe': '<circle cx="12" cy="12" r="9"/><ellipse cx="12" cy="12" rx="4" ry="9"/><path d="M3 12h18"/>',
        'code': '<path d="m8 6-6 6 6 6m8-12 6 6-6 6m-3-14-2 16"/>',
        'clipboard': '<rect x="5" y="5" width="14" height="16" rx="2"/><rect x="8" y="2" width="8" height="5" rx="1"/>',
        'shield': '<path d="m12 2 8 4v6c0 5-8 10-8 10S4 17 4 12V6z"/><rect x="9" y="10" width="6" height="6" rx="1"/><path d="M10 10V8a2 2 0 0 1 4 0v2"/>',
        'grid': '<rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/>',
        'note': '<path d="M5 3h14v18H5zm4 5h6m-6 4h6m-6 4h4"/>',
        'image': '<rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8" cy="8" r="2"/><path d="m3 17 6-5 4 4 4-7 4 8"/>',
        'play': '<path d="m9 5 10 7-10 7z"/>',
        'previous': '<path d="M5 5v14m14-14L8 12l11 7z"/>',
        'next': '<path d="M19 5v14M5 5l11 7-11 7z"/>',
        'search': '<circle cx="10" cy="10" r="6"/><path d="m15 15 6 6"/>',
        'clock': '<circle cx="12" cy="12" r="9"/><path d="M12 6v6l4 2"/>',
    }
    return f'<svg width="{size}" height="{size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.65" stroke-linecap="round" stroke-linejoin="round">{paths[name]}</svg>'

landscape = '''<svg viewBox="0 0 440 230" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg"><path fill="#9CBAB7" d="M0 0h440v230H0z"/><circle cx="320" cy="60" r="29" fill="#E4D8B2"/><path d="M0 147Q60 85 130 140T260 140T440 100V230H0" fill="#55786B"/><path d="M0 190Q100 115 205 180T440 145V230H0" fill="#344E4A"/><path d="M195 230Q250 195 208 173Q200 165 235 155Q222 182 260 199L285 230" fill="#AAC8BB"/></svg>'''
clock = '<div class="widget clock"><div><div class="time">20<span>:</span>24</div><div class="muted">segunda-feira, 14 de abril</div></div><div class="dial"><i></i><b></b><em></em></div></div>'
media = f'''<div class="widget media"><div class="cover"><span>DAYZ</span><div></div><small>STUDIO SESSION</small></div><div class="track"><strong>Sessão acústica</strong><p>Dayz Studio</p><div class="transport">{icon('previous',17)}<b>{icon('play',19)}</b>{icon('next',17)}</div></div><div class="timeline"><small>0:42</small><div><i></i></div><small>3:18</small></div></div>'''
shortcuts = '<div class="widget shortcuts">'+''.join(f'<div>{icon(x,24)}</div>' for x in ['folder','terminal','globe','code','note','clipboard','image'])+'</div>'
hub = '<div class="widget hub"><div class="tabs"><span>Painel</span><span>Desempenho</span><span>Clima</span><span class="selected">Ferramentas</span></div><div class="search">'+icon('search',15)+'<span>Buscar ferramenta</span></div><div class="tools">'+''.join(f'<div>{icon(i,19)}<p>{n}<small>{d}</small></p></div>' for i,n,d in [('clock','Relógio','Hora e calendário'),('note','Notas rápidas','Suas ideias à mão'),('folder','Arquivos','Abrir pastas locais'),('shield','Bitwarden','Acesso ao cofre'),('clipboard','Clipboard','Histórico de cópia'),('image','Wallpapers','Escolher imagem')])+'</div></div>'
gallery = f'<div class="widget gallery">{landscape}<div><p>Paisagens<small>3840×2160 · clique para avançar</small></p>{icon("image",20)}</div></div>'
commands = '<div class="widget commands"><header>'+icon('terminal',20)+'<b>Meus Comandos</b><small>3 comandos</small></header><div class="search">'+icon('search',15)+'<span>Buscar comando</span></div><div class="chips"><b>Todos</b><span>Shell</span><span>Scripts</span><span>Atalhos</span></div>'+''.join(f'<article><div><strong>{n}</strong><small>{d}</small></div>{icon("clipboard",16)}</article>' for n,d in [('projeto','Abrir pasta de desenvolvimento'),('status','Consultar estado local'),('ajuda','Consultar catálogo de comandos')])+'</div>'
bitwarden = f'<div class="bitwarden"><div class="widget bar"><span>{icon("grid",17)}</span><small>20:24</small><span class="vault">{icon("shield",22)}</span></div><div class="tip">Bitwarden</div><div class="vault-caption">Acesso compacto ao daemon compartilhado</div></div>'
theme = '<div class="widget theme"><h2>Graphite</h2><p>Superfícies discretas. Contraste claro.</p><div class="swatches">'+''.join(f'<i style="background:{c}"></i>' for c in ['#202528','#343B3F','#A6B8A5','#A5B3BC','#B5ADA2','#EDF0EC'])+'</div><div class="theme-labels"><span>Surface</span><span>Primary</span><span>Text</span></div></div>'
previews = [('quiet-clock',clock),('media-card',media),('hub',hub),('shortcuts',shortcuts),('gallery',gallery),('commands',commands),('bitwarden',bitwarden),('graphite',theme)]
style = '''*{box-sizing:border-box}body{margin:0;background:#111619;color:#EDF0EC;font:14px "DejaVu Sans",sans-serif}.sheet{display:grid;grid-template-columns:600px 600px}.tile{width:600px;height:350px;display:flex;align-items:center;justify-content:center;background:#111619;border:1px solid #1a2225}.widget{background:#202528;border:1px solid #35403e;border-radius:18px}.muted,small,p{color:#B2BCB8}small{font-size:11px}.clock{width:440px;height:158px;padding:26px;display:flex;align-items:center;justify-content:space-between}.time{font-size:56px;font-weight:300;line-height:1.15;margin-bottom:8px;letter-spacing:-2px}.time span{color:#A6B8A5}.muted{font-size:12px}.dial{width:65px;height:65px;border:3px dotted #737e78;border-radius:50%;position:relative}.dial i,.dial b{position:absolute;left:29px;bottom:29px;transform-origin:bottom;background:#A6B8A5;border-radius:5px;width:2px;height:23px;transform:rotate(144deg)}.dial b{height:16px;width:3px;background:#EDF0EC;transform:rotate(252deg)}.dial em{position:absolute;left:27px;top:27px;width:6px;height:6px;border-radius:50%;background:#A6B8A5}.media{width:440px;height:176px;padding:20px;position:relative;display:flex;gap:18px}.cover{width:88px;height:88px;border-radius:12px;background:#C8B58A;color:#24211d;text-align:center;position:relative;overflow:hidden;padding-top:6px}.cover span{font-size:11px;letter-spacing:4px}.cover div{width:35px;height:35px;background:#354237;border-radius:50%;margin:3px auto}.cover small{font-size:7px;color:#24211d}.track{padding-top:2px}.track strong{font-size:15px;font-weight:500}.track p{font-size:12px;margin:6px 0 10px}.transport{display:flex;align-items:center;gap:14px;color:#EDF0EC}.transport b{background:#A6B8A5;color:#1B211C;border-radius:11px;display:flex;width:34px;height:34px;align-items:center;justify-content:center}.timeline{position:absolute;bottom:17px;left:20px;right:20px;display:flex;align-items:center;gap:10px}.timeline>div{height:3px;background:#3A4345;flex:1}.timeline i{display:block;width:22%;height:3px;background:#A6B8A5}.shortcuts{padding:15px;display:flex;gap:9px;align-items:center;border-radius:14px}.shortcuts>div{display:flex;align-items:center;justify-content:center;width:44px;height:40px;color:#D2DBD2}.hub{width:530px;padding:14px;border-radius:18px}.tabs{display:flex;gap:5px;margin-bottom:12px;font-size:11px}.tabs span{flex:1;text-align:center;padding:9px 3px;border-radius:12px;background:#2c3435;color:#B2BCB8}.tabs .selected{background:#3a4740;border:1px solid #737e78;color:#dbe5d8}.search{display:flex;gap:8px;align-items:center;color:#a9b7b2;font-size:11px;background:#30383b;border-radius:12px;padding:9px 12px;margin-bottom:12px}.tools{display:grid;grid-template-columns:repeat(3,1fr);gap:8px}.tools>div{display:flex;gap:10px;align-items:center;background:#2b3334;border-radius:12px;padding:11px 9px;color:#A6B8A5}.tools p{font-size:11px;margin:0;color:#edf0ec;line-height:1.4}.tools small{display:block;font-size:9px;color:#B2BCB8}.gallery{width:440px;overflow:hidden}.gallery>svg{display:block;width:440px;height:205px;object-fit:cover}.gallery>div{display:flex;justify-content:space-between;align-items:center;padding:11px 15px}.gallery p{margin:0;color:#edf0ec;font-size:13px}.gallery small{display:block;margin-top:4px}.commands{width:470px;padding:17px}.commands header{display:flex;align-items:center;gap:8px;margin-bottom:13px}.commands header small{margin-left:auto}.chips{display:flex;gap:15px;font-size:11px;color:#B2BCB8;align-items:center;margin-bottom:8px}.chips b{background:#3a4740;color:#dbe5d8;border-radius:9px;padding:5px 10px;font-weight:400}.commands article{display:flex;align-items:center;justify-content:space-between;border-top:1px solid #353D3B;padding:10px 2px}.commands article strong{font-weight:500;font-size:12px}.commands article small{display:block;margin-top:3px}.bitwarden{width:460px;text-align:center}.bar{display:flex;align-items:center;justify-content:space-between;border-radius:14px;padding:13px 19px}.bar span{display:flex}.bar .vault{color:#A6B8A5}.tip{display:inline-block;border:1px solid #35403e;border-radius:9px;background:#272D30;padding:7px 11px;margin-top:8px;font-size:11px;float:right}.vault-caption{clear:both;padding-top:24px;font-size:12px;color:#B2BCB8}.theme{width:440px;padding:28px}.theme h2{margin:0;font-weight:500;font-size:24px}.theme p{font-size:12px;margin:7px 0 22px}.swatches{display:flex;gap:9px}.swatches i{display:block;width:52px;height:50px;border-radius:10px;border:1px solid #737e7855}.theme-labels{display:flex;justify-content:space-between;color:#B2BCB8;font-size:10px;margin-top:10px}'''

def main():
    chromium = shutil.which('chromium') or shutil.which('google-chrome')
    if not chromium or not shutil.which('magick'):
        raise SystemExit('Requer Chromium/Chrome e ImageMagick (magick).')
    OUT.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='dayz-previews-') as temp:
        temp = Path(temp)
        html = temp / 'previews.html'
        html.write_text('<!doctype html><meta charset="utf-8"><style>'+style+'</style><div class="sheet">'+''.join('<div class="tile">'+body+'</div>' for _,body in previews)+'</div>')
        shot = temp / 'sheet.png'
        subprocess.run([chromium,'--headless','--no-sandbox','--disable-gpu','--no-first-run','--disable-background-networking','--disable-sync','--disable-extensions','--user-data-dir='+str(temp/'profile'),'--hide-scrollbars','--force-device-scale-factor=1','--window-size=1200,1400','--virtual-time-budget=1000','--screenshot='+str(shot),html.as_uri()],check=True,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
        for index,(name,_) in enumerate(previews):
            geometry = f'600x350+{index%2*600}+{index//2*350}'
            subprocess.run(['magick',str(shot),'-crop',geometry,'+repage',str(OUT/(name+'.png'))],check=True)
    print('8 prévias ilustrativas renderizadas em docs/previews/')

if __name__ == '__main__':
    main()
