<?php
declare(strict_types=1);
// All website files pass through this controller; the password hash stays outside htdocs.
ini_set('session.use_strict_mode', '1');
ini_set('session.use_cookies', '1');
ini_set('session.use_only_cookies', '1');
// Shared hosting may provide an unwritable default session directory.
$sessionDir = sys_get_temp_dir() . '/sonnenhain-sessions-' . substr(hash('sha256', __DIR__), 0, 16);
if (!is_dir($sessionDir) && !@mkdir($sessionDir, 0700)) {
    http_response_code(503); exit('Der Zugang ist kurzzeitig nicht verfügbar.');
}
ini_set('session.save_handler', 'files');
session_save_path($sessionDir);
session_name('sonnenhain_access');
session_set_cookie_params(['lifetime' => 0, 'path' => '/', 'secure' => true, 'httponly' => true, 'samesite' => 'Lax']);
if (!session_start()) { http_response_code(503); exit('Die Anmeldung ist kurzzeitig nicht verfügbar.'); }
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('X-Content-Type-Options: nosniff');
header('Referrer-Policy: no-referrer');

function destination(string $path): string {
    if ($path === '' || $path[0] !== '/' || substr($path, 0, 2) === '//' || preg_match('/[\\\\\x00-\x20\x7f]/', $path)) return '/';
    return $path;
}
$hashFile = getenv('SONNENHAIN_ACCESS_FILE') ?: '/home/sites/site100047525/web/sonnenhain-access.htpasswd';
$entry = @file_get_contents($hashFile);
$hash = $entry === false ? '' : trim(explode(':', $entry, 2)[1] ?? '');
if ($hash === '' || password_get_info($hash)['algoName'] === 'unknown') {
    http_response_code(503); exit('Der Zugang wird gerade vorbereitet. Bitte versuche es gleich erneut.');
}
$fingerprint = hash('sha256', $hash);
$authenticated = isset($_SESSION['access'], $_SESSION['until']) && hash_equals($fingerprint, (string) $_SESSION['access']) && (int) $_SESSION['until'] > time();
$uri = $_SERVER['REQUEST_URI'] ?? '/';
$route = rawurldecode(parse_url($uri, PHP_URL_PATH) ?: '/');
$login = $route === '/login' || $route === '/access.php';
$next = destination((string) ($_POST['next'] ?? $_GET['next'] ?? '/'));
$error = '';
if (!isset($_SESSION['csrf'])) $_SESSION['csrf'] = bin2hex(random_bytes(24));

if ($login && ($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST') {
    if (!hash_equals((string) $_SESSION['csrf'], (string) ($_POST['csrf'] ?? ''))) {
        http_response_code(403); $error = 'Bitte lade die Seite neu und versuche es erneut.';
    } else {
        // Server-side rate limiting survives a new browser session or cookie deletion.
        $limitDir = sys_get_temp_dir() . '/sonnenhain-login-' . substr(hash('sha256', __DIR__), 0, 16);
        if (!is_dir($limitDir)) @mkdir($limitDir, 0700);
        $limitFile = $limitDir . '/' . hash('sha256', $_SERVER['REMOTE_ADDR'] ?? 'unknown');
        $lock = @fopen($limitFile, 'c+');
        if ($lock === false || !flock($lock, LOCK_EX)) {
            http_response_code(503); $error = 'Der Zugang ist kurzzeitig nicht verfügbar.';
        } else {
            $attempts = json_decode(stream_get_contents($lock) ?: '[]', true) ?: [];
            $attempts = array_values(array_filter($attempts, static function ($stamp) { return is_int($stamp) && $stamp > time() - 300; }));
            if (count($attempts) >= 10) {
                http_response_code(429); header('Retry-After: 300'); $error = 'Zu viele Versuche. Bitte warte fünf Minuten.';
            } elseif (strlen((string) ($_POST['password'] ?? '')) <= 1024 && password_verify((string) ($_POST['password'] ?? ''), $hash)) {
                session_regenerate_id(true);
                $_SESSION['access'] = $fingerprint; $_SESSION['until'] = time() + 43200;
                $_SESSION['csrf'] = bin2hex(random_bytes(24));
                $attempts = []; $authenticated = true;
            } else {
                $attempts[] = time(); http_response_code(401); $error = 'Das Passwort stimmt nicht.';
            }
            rewind($lock); ftruncate($lock, 0); fwrite($lock, json_encode($attempts)); fflush($lock); flock($lock, LOCK_UN); fclose($lock);
        }
    }
    if ($authenticated && $error === '') { session_write_close(); header('Location: ' . $next, true, 303); exit; }
}
if ($login) {
    if ($authenticated && ($_SERVER['REQUEST_METHOD'] ?? 'GET') !== 'POST') { session_write_close(); header('Location: ' . $next, true, 303); exit; }
    header("Content-Security-Policy: default-src 'none'; style-src 'unsafe-inline'; form-action 'self'; base-uri 'none'; frame-ancestors 'none'");
    $csrf = htmlspecialchars((string) $_SESSION['csrf'], ENT_QUOTES, 'UTF-8');
    $target = htmlspecialchars($next, ENT_QUOTES, 'UTF-8');
    $message = htmlspecialchars($error, ENT_QUOTES, 'UTF-8');
    session_write_close();
    ?>
<!doctype html><html lang="de"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="noindex,nofollow"><title>Sonnenhain · Zugang</title><style>
*{box-sizing:border-box}body{margin:0;min-height:100vh;display:grid;place-items:center;background:#091b29;color:#ffe2aa;font-family:system-ui,sans-serif;padding:24px}main{width:min(100%,480px);padding:36px;background:#10283c;border:3px solid #c9a45e;box-shadow:0 0 0 6px #162f42}h1{letter-spacing:.08em;font-size:32px;margin:0 0 12px}p{color:#ccdbd0;line-height:1.5}label{display:block;margin:24px 0 8px}input,button{width:100%;font:inherit;padding:14px;border:2px solid #c9a45e;border-radius:0}input{background:#091b29;color:#fff}button{margin-top:18px;background:#c9a45e;color:#091b29;font-weight:700;cursor:pointer}input:focus,button:focus{outline:3px solid #90dfdf;outline-offset:3px}.error{color:#ffba9e;min-height:24px;font-size:14px}
</style></head><body><main><h1>SONNENHAIN</h1><p>Gib das Zugangspasswort ein, um die Website und das Spiel zu öffnen.</p><form method="post" action="/login"><input type="hidden" name="csrf" value="<?= $csrf ?>"><input type="hidden" name="next" value="<?= $target ?>"><label for="password">Passwort</label><input id="password" name="password" type="password" autocomplete="current-password" maxlength="1024" required autofocus><button type="submit">SONNENHAIN ÖFFNEN</button><p class="error" role="alert"><?= $message ?></p></form></main></body></html>
    <?php exit;
}
if (!$authenticated) { session_write_close(); header('Location: /login?next=' . rawurlencode(destination($uri)), true, 302); exit; }
session_write_close(); // Parallel game downloads must not hold the session lock.
if (!in_array($_SERVER['REQUEST_METHOD'] ?? 'GET', ['GET', 'HEAD'], true)) { http_response_code(405); header('Allow: GET, HEAD'); exit; }
$root = realpath(__DIR__);
if (strpos($route, "\0") !== false || preg_match('~(?:^|/)[.]|[\\\\]~', $route)) { http_response_code(404); exit; }
$file = realpath($root . '/' . ltrim($route, '/'));
if ($file !== false && is_dir($file)) $file = realpath($file . '/index.html');
if ($file === false || strpos($file, $root . DIRECTORY_SEPARATOR) !== 0 || !is_file($file) || preg_match('/\.(php[0-9]?|phtml|phar|htpasswd)$/i', $file)) { http_response_code(404); exit; }
$types = ['html'=>'text/html; charset=utf-8','css'=>'text/css; charset=utf-8','js'=>'application/javascript','json'=>'application/json','wasm'=>'application/wasm','png'=>'image/png','jpg'=>'image/jpeg','jpeg'=>'image/jpeg','webp'=>'image/webp','svg'=>'image/svg+xml','ico'=>'image/x-icon','ogg'=>'audio/ogg','mp3'=>'audio/mpeg','wav'=>'audio/wav','woff'=>'font/woff','woff2'=>'font/woff2','txt'=>'text/plain; charset=utf-8'];
header('Content-Type: ' . ($types[strtolower(pathinfo($file, PATHINFO_EXTENSION))] ?? 'application/octet-stream'));
$size = filesize($file); $start = 0; $end = $size - 1;
header('Accept-Ranges: bytes');
if (isset($_SERVER['HTTP_RANGE'])) {
    if (!preg_match('/^bytes=(\d*)-(\d*)$/', $_SERVER['HTTP_RANGE'], $range) || ($range[1] === '' && $range[2] === '')) { http_response_code(416); header('Content-Range: bytes */' . $size); exit; }
    if ($range[1] === '') { $start = max(0, $size - (int) $range[2]); }
    else { $start = (int) $range[1]; if ($range[2] !== '') $end = min($end, (int) $range[2]); }
    if ($start > $end || $start >= $size) { http_response_code(416); header('Content-Range: bytes */' . $size); exit; }
    http_response_code(206); header("Content-Range: bytes $start-$end/$size");
}
header('Content-Length: ' . max(0, $end - $start + 1));
if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'HEAD' || $size === 0) exit;
$stream = fopen($file, 'rb'); fseek($stream, $start); $remaining = $end - $start + 1;
while ($remaining > 0 && !feof($stream) && !connection_aborted()) { $data = fread($stream, min(1048576, $remaining)); if ($data === false || $data === '') break; echo $data; $remaining -= strlen($data); }
fclose($stream);
