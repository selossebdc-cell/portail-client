const SUPABASE_URL = 'https://dcynlifggjiqqihincbp.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRjeW5saWZnZ2ppcXFpaGluY2JwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM2NTUyNTIsImV4cCI6MjA4OTIzMTI1Mn0.zsJnkswhmnzLCcO--0PwxJtIfTFL8C2p6_gqMM-V3bI';

const db = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
