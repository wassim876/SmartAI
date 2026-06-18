# test-all-endpoints.ps1
Write-Host "🚀 TESTING ALL ENDPOINTS" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Yellow

# Login
Write-Host "`n1️⃣ Logging in..." -ForegroundColor Green
$loginBody = @{
    username = "testuser"
    password = "testpass123"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "http://localhost:8000/api/token/" -Method Post -Body $loginBody -ContentType "application/json"
$token = $loginResponse.access
Write-Host "✅ Login successful!" -ForegroundColor Green

$headers = @{ "Authorization" = "Bearer $token" }

# 2. Get Profile
Write-Host "`n2️⃣ Getting profile..." -ForegroundColor Green
$profile = Invoke-RestMethod -Uri "http://localhost:8000/api/user/profile/" -Method Get -Headers $headers
Write-Host "✅ Profile retrieved!" -ForegroundColor Green
Write-Host "  Username: $($profile.username)" -ForegroundColor White
Write-Host "  Email: $($profile.email)" -ForegroundColor White

# 3. Save Chat
Write-Host "`n3️⃣ Saving chat message..." -ForegroundColor Green
$chatBody = @{
    message = "Hello AI!"
    response = "Hello! How can I help you?"
    model = "gpt-3.5-turbo"
} | ConvertTo-Json

$chat = Invoke-RestMethod -Uri "http://localhost:8000/api/chat/save/" -Method Post -Body $chatBody -ContentType "application/json" -Headers $headers
Write-Host "✅ Chat saved! ID: $($chat.data.id)" -ForegroundColor Green

# 4. Get Chat History
Write-Host "`n4️⃣ Getting chat history..." -ForegroundColor Green
$history = Invoke-RestMethod -Uri "http://localhost:8000/api/chat/history/" -Method Get -Headers $headers
Write-Host "✅ Chat history retrieved! Count: $($history.count)" -ForegroundColor Green

# 5. Save Image Analysis
Write-Host "`n5️⃣ Saving image analysis..." -ForegroundColor Green
$imageBody = @{
    image_url = "https://example.com/sunset.jpg"
    analysis_result = "Beautiful sunset with orange colors"
    image_type = "nature"
} | ConvertTo-Json

$image = Invoke-RestMethod -Uri "http://localhost:8000/api/image-analysis/save/" -Method Post -Body $imageBody -ContentType "application/json" -Headers $headers
Write-Host "✅ Image analysis saved! ID: $($image.data.id)" -ForegroundColor Green

# 6. Save Translation
Write-Host "`n6️⃣ Saving translation..." -ForegroundColor Green
$transBody = @{
    original_text = "Hello"
    translated_text = "Bonjour"
    source_lang = "en"
    target_lang = "fr"
} | ConvertTo-Json

$trans = Invoke-RestMethod -Uri "http://localhost:8000/api/translation/save/" -Method Post -Body $transBody -ContentType "application/json" -Headers $headers
Write-Host "✅ Translation saved! ID: $($trans.data.id)" -ForegroundColor Green

# 7. Save Speech
Write-Host "`n7️⃣ Saving speech transcription..." -ForegroundColor Green
$speechBody = @{
    audio_url = "https://example.com/audio.mp3"
    transcription = "Hello world, test transcription"
    duration = 5.2
} | ConvertTo-Json

$speech = Invoke-RestMethod -Uri "http://localhost:8000/api/speech/save/" -Method Post -Body $speechBody -ContentType "application/json" -Headers $headers
Write-Host "✅ Speech saved! ID: $($speech.data.id)" -ForegroundColor Green

# 8. Get Activities
Write-Host "`n8️⃣ Getting activities..." -ForegroundColor Green
$activities = Invoke-RestMethod -Uri "http://localhost:8000/api/activities/" -Method Get -Headers $headers
Write-Host "✅ Activities retrieved! Count: $($activities.count)" -ForegroundColor Green

Write-Host "`n=========================" -ForegroundColor Yellow
Write-Host "✅ All tests passed!" -ForegroundColor Cyan