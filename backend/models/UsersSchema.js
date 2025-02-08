const mongoose=require('mongoose') ;

const usersSchema = new mongoose.Schema({
    username: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    resetToken: {type:String},
    resetTokenExpiration: {type:Date},
    phoneNumber:{type:Number}
  });
  
module.exports=mongoose.model('User',usersSchema);