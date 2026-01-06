" ===============================
" 기본 사용성
" ===============================
set nocompatible        " 옛날 vi 호환 끄기
set encoding=utf-8
set fileencoding=utf-8
set number              " 줄 번호
set ruler               " 커서 위치 표시
set showcmd             " 입력 중 명령 표시
set wildmenu            " 자동완성 메뉴
set mouse=a             " 마우스 허용 (터미널에서도 편함)

" ===============================
" 탭 / 들여쓰기 (중요)
" ===============================
set tabstop=4           " TAB을 4칸으로 표시
set shiftwidth=4        " >> << 들여쓰기 4칸
set softtabstop=4       " 탭 누를 때 4칸
set expandtab           " TAB을 스페이스로 변환
set autoindent          " 자동 들여쓰기
set smartindent         " 문법 기반 들여쓰기

" ⚠️ 탭 8칸 지옥에서 탈출 핵심:
" tabstop / shiftwidth / softtabstop 이 셋이 같아야 함

" ===============================
" 검색
" ===============================
set ignorecase          " 대소문자 무시
set smartcase           " 대문자 포함 시 대소문자 구분
set incsearch           " 입력 중 검색
set hlsearch            " 검색어 하이라이트

" ===============================
" 화면 / UX
" ===============================
set nowrap              " 자동 줄바꿈 끄기
set scrolloff=5         " 위아래 여백
set sidescrolloff=5
set cursorline          " 현재 줄 강조
set laststatus=2        " 상태바 항상 표시

" ===============================
" 파일
" ===============================
set backup              " 백업 파일 생성
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set undofile            " undo 기록 유지
set undodir=~/.vim/undo//

" ===============================
" 기타
" ===============================
syntax on               " 문법 하이라이트
set hidden              " 저장 안 해도 버퍼 이동 가능
set noerrorbells
set visualbell
set t_vb=


vnoremap < <gv
vnoremap > >gv
