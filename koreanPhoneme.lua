SCRIPT_TITLE = "한국어 발음 생성(반드시 후처리 하시오)"

-- 초성, 중성, 종성 리스트
local CHOSUNG_LIST = {'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'}
local JUNGSEUNG_LIST = {'ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ', 'ㅘ', 'ㅙ', 'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ', 'ㅢ', 'ㅣ'}
local JONGSEUNG_LIST = {' ', 'ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ', 'ㄺ', 'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'}

-- 1. 모음 유형 분류
local VOWEL_STYLE = {
    ['일본어'] = {['ㅏ'] = true, ['ㅑ'] = true, ['ㅗ'] = true, ['ㅛ'] = true, ['ㅜ'] = true, ['ㅠ'] = true, ['ㅣ'] = true, ['ㅐ'] = true, ['ㅔ'] = true, ['ㅒ'] = true, ['ㅖ'] = true, ['ㅘ'] = true, ['ㅙ'] = true, ['ㅚ'] = true, ['ㅞ'] = true, ['ㅟ'] = true},
    ['중국어'] = {['ㅓ'] = true, ['ㅕ'] = true, ['ㅝ'] = true, ['ㅡ'] = true, ['ㅢ'] = true}
}
-- 검색 성능을 위해 배열 대신 키-값 형태의 테이블로 변경

-- 2. 음소 매핑 테이블
local PHONEME_MAP = {
    ['일본어'] = {
        ['초성'] = {['ㄱ']='g', ['ㄲ']='cl k', ['ㄴ']='n', ['ㄷ']='d', ['ㄸ']='cl t', ['ㄹ']='r', ['ㅁ']='m', ['ㅂ']='b', ['ㅃ']='cl p', ['ㅅ']='s', ['ㅆ']='ss', ['ㅇ']='', ['ㅈ']='j', ['ㅉ']='cl ch', ['ㅊ']='ch', ['ㅋ']='k', ['ㅌ']='t', ['ㅍ']='p', ['ㅎ']='h'},
        ['중성'] = {['ㅏ']='a', ['ㅑ']='i a', ['ㅗ']='o', ['ㅛ']='i o', ['ㅜ']='u', ['ㅠ']='i u', ['ㅣ']='i', ['ㅐ']='e', ['ㅔ']='e', ['ㅒ']='i e', ['ㅖ']='i e', ['ㅘ']='w a', ['ㅙ']='w e', ['ㅚ']='w e', ['ㅞ']='w e', ['ㅟ']='w i'}, -- 원본 JS의 'ㅟ'에 대한 매핑이 없어 추가함
        ['종성'] = {['ㄱ']='g', ['ㄲ']='g', ['ㄴ']='n', ['ㄷ']='d', ['ㄹ']='r', ['ㅁ']='m', ['ㅂ']='b', ['ㅅ']='d', ['ㅆ']='d', ['ㅇ']='N', ['ㅈ']='d', ['ㅊ']='d', ['ㅋ']='g', ['ㅌ']='d', ['ㅍ']='b', ['ㅎ']='d'}
    },
    ['중국어'] = {
        ['초성'] = {['ㄱ']='k', ['ㄲ']='cl kh', ['ㄴ']='n', ['ㄷ']='t', ['ㄸ']='cl th', ['ㄹ']='l', ['ㅁ']='m', ['ㅂ']='p', ['ㅃ']='cl ph', ['ㅅ']='s', ['ㅆ']='cl s', ['ㅇ']='', ['ㅈ']='ts\\', ['ㅉ']='cl ts`h', ['ㅊ']='ts`h', ['ㅋ']='kh', ['ㅌ']='th', ['ㅍ']='ph', ['ㅎ']='x'},
        ['중성'] = {['ㅓ']='7', ['ㅕ']='i 7', ['ㅝ']='w 7', ['ㅡ']='i\\', ['ㅢ']='i\\ i'},
        ['종성'] = {['ㄱ']='k', ['ㄲ']='k', ['ㄴ']='n', ['ㄷ']='t', ['ㄹ']='l', ['ㅁ']='m', ['ㅂ']='p', ['ㅅ']='t', ['ㅆ']='t', ['ㅇ']='N', ['ㅈ']='t', ['ㅊ']='t', ['ㅋ']='k', ['ㅌ']='t', ['ㅍ']='p', ['ㅎ']='t'}
    }
}

-- 3. 겹받침 분리 규칙
local DOUBLE_JONGSEUNG_MAP = {
    ['ㄳ'] = {'ㄱ', 'ㅅ'}, ['ㄵ'] = {'ㄴ', 'ㅈ'}, ['ㄶ'] = {'ㄴ', 'ㅎ'},
    ['ㄺ'] = {'ㄹ', 'ㄱ'}, ['ㄻ'] = {'ㄹ', 'ㅁ'}, ['ㄼ'] = {'ㄹ', 'ㅂ'},
    ['ㄽ'] = {'ㄹ', 'ㅅ'}, ['ㄾ'] = {'ㄹ', 'ㅌ'}, ['ㄿ'] = {'ㄹ', 'ㅍ'},
    ['ㅀ'] = {'ㄹ', 'ㅎ'}, ['ㅄ'] = {'ㅂ', 'ㅅ'}
}

-- 한글 문자를 음소로 변환하는 함수
local function koreanToPhoneme(note)
    local char = note:getLyrics()
    local mdr = true
    local charCode = utf8.codepoint(char)

    -- 한글 음절 범위 확인 (가 ~ 힣)
    if charCode >= 44032 and charCode <= 55203 then
        local hangulCode = charCode - 44032

        -- 1. 자모 분리 (0-based index)
        local choseongIdx_0 = math.floor(hangulCode / (21 * 28))
        local jungseongIdx_0 = math.floor((hangulCode % (21 * 28)) / 28)
        local jongseongIdx_0 = hangulCode % 28

        -- Lua는 1-based index이므로 +1 하여 조회
        local ch = CHOSUNG_LIST[choseongIdx_0 + 1]
        local ju = JUNGSEUNG_LIST[jungseongIdx_0 + 1]
        local jo_char = JONGSEUNG_LIST[jongseongIdx_0 + 1]

        -- 2. 모음 유형 판단
        local style = '중국어' -- 기본값
        if VOWEL_STYLE['일본어'][ju] then
            style = '일본어'
            mdr=false
        end

        -- 3. 음소 변환
        local cho_phoneme = PHONEME_MAP[style]['초성'][ch]
        local jung_phoneme = PHONEME_MAP[style]['중성'][ju]
        local jong_phonemes = {}

        if jo_char ~= ' ' then -- 종성이 있는 경우
            if DOUBLE_JONGSEUNG_MAP[jo_char] then -- 겹받침인 경우
                local jamo_pair = DOUBLE_JONGSEUNG_MAP[jo_char]
                local j1 = jamo_pair[1]
                local j2 = jamo_pair[2]
                table.insert(jong_phonemes, PHONEME_MAP[style]['종성'][j1])
                table.insert(jong_phonemes, PHONEME_MAP[style]['초성'][j2]) -- 원본 로직: 두 번째 자음은 초성 규칙을 따름
            else -- 홑받침인 경우
                table.insert(jong_phonemes, PHONEME_MAP[style]['종성'][jo_char])
            end
        end

        -- 결과 조합
        local syllable_parts = {cho_phoneme, jung_phoneme}
        for i = 1, #jong_phonemes do
            table.insert(syllable_parts, jong_phonemes[i])
        end

        -- nil이나 빈 문자열을 제외하고 합치기
        local final_parts = {}
        for _, part in ipairs(syllable_parts) do
            if part and part ~= '' then
                table.insert(final_parts, part)
            end
        end
        
        local res = table.concat(final_parts, " ")
        note:setPhonemes(SV:T(res))
        if mdr then
            note:setLanguageOverride("mandarin")
        end

    else -- 한글이 아니면 그대로 반환
        local res = char
    end
end

function getClientInfo()
  return {
    name = SV:T(SCRIPT_TITLE),
    author = "Flestal",
    versionNumber = 1,
    minEditorVersion = 65537
  }
end

function main()
    local selectedGroup = SV:getMainEditor():getCurrentGroup()
    local noteNum = selectedGroup:getTarget():getNumNotes()
    for i=1,noteNum do
        local note = selectedGroup:getTarget():getNote(i)
        if note then
            koreanToPhoneme(note)
        end
    end
end