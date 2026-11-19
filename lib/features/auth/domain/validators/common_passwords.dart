/// Most-used passwords (lowercase). Matching is done on the lowercased
/// password and on the password with trailing digits/symbols stripped, so
/// `Password123!` is caught too.
const Set<String> kCommonPasswords = {
  '123456', '1234567', '12345678', '123456789', '1234567890', '12345',
  '111111', '000000', '121212', '654321', '666666', '123123', '112233',
  '987654321', '123321', '11111111', '00000000', '12341234', '1q2w3e4r',
  'password', 'password1', 'passw0rd', 'p@ssw0rd', 'p@ssword', 'pass1234',
  'admin', 'admin123', 'administrator', 'root', 'toor', 'welcome',
  'welcome1', 'login', 'letmein', 'iloveyou', 'monkey', 'dragon', 'master',
  'sunshine', 'princess', 'football', 'baseball', 'soccer', 'superman',
  'batman', 'trustno1', 'shadow', 'qwerty', 'qwerty123', 'qwertyuiop',
  'qazwsx', 'asdfgh', 'asdfghjkl', 'zxcvbn', 'zxcvbnm', '1qaz2wsx',
  'abc123', 'abcd1234', 'abcdefg', 'test', 'test123', 'guest', 'user',
  'changeme', 'default', 'secret', 'hello', 'hello123', 'freedom',
  'whatever', 'michael', 'jennifer', 'jordan', 'jordan123', 'saudi',
  'egypt', 'egypt123', 'ahmed', 'ahmad', 'mohamed', 'mohammed', 'mohammad',
  'omar', 'ali123', 'allah', 'allah123', 'bismillah', 'jabal', 'jabal123',
  'drjabal', 'drjabel', 'pharmacy', 'pharmacy1',
  // Arabic-keyboard digits/words people commonly use
  'كلمةالمرور', 'كلمةسر', 'مرحبا', 'محمد', 'احمد',
};
