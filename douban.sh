#/bin/bash
 
# name:         get_see_movies.sh
# description:  输入豆瓣用户id,获取所有评论过的电影、评分、短评内容
# author:       mwl
 
# description：	判断输入参数是否合理
 
#INFO打印
info_log(){
    echo -e "[INFO]$1"
}
 
#SUCCESS打印
 
success_log(){
    echo -e "\033[32m[SUCCESS]\033[0m$1"
}
 
#ERROR打印
error_log(){
    echo -e "\033[31m[ERROR]\033[0m$1"
}
 
if [ $# -eq 1 ];then
    if [ -n "$(echo $1| sed -n "/^[0-9]\+$/p")" ];then
        info_log "The user id you searched for is $1"
    else
        error_log "The user id must number"
        exit 1
    fi
else
	error_log "Usage: bash $0 162545416";
	exit 1
fi
#测试用例 182580804
# movie_number=`curl -s https://movie.douban.com/people/$1/collect|egrep "看过的电影"|awk -F '(' '{print $2}' |awk -F ')' '{print $1}'|uniq`
user_name=`curl -s https://movie.douban.com/people/$1/collect|egrep "看过的电影"|awk -F '看过的电影' '{print $1}'|awk -F '>' '{print $2}'|tail -n1`
comment_number=`curl -s https://movie.douban.com/people/$1/reviews|egrep "电影解毒的影评"|awk -F "影评" '{print $2}'|grep -Po '(?<=\().*(?=\))'|tail -n1`
info_log "$user_name 发表了 $comment_number 篇影评"
info_log '查询中 请稍候....'

for i in `seq 0 10 $comment_number`;do
    curl -s https://movie.douban.com/people/$1/reviews?start=$i > html
    cat html |egrep "评论:"|awk -F '评论:' '{print $2}'|awk '/《/{print $3}'|awk -F '<' '{print $1}' > movie_name.txt
    cat html |egrep "allstar"|awk '{print $3}'|awk -F '"' '{ print $2 }' > comment_rate.txt
    cat html |egrep "title.*moreurl"|awk -F '"' '{ print $4 }' > comment_content.txt
    cat html |egrep "img.*fil"|awk -F '"' '{ print $4 }' > movie_picture.txt
    for j in $(seq 1 10);do
        movie_name=`cat movie_name.txt|tail -n +$j | head -n 1`
        comment_rate=`cat comment_rate.txt|tail -n +$j | head -n 1`
        comment_content=`cat comment_content.txt|tail -n +$j | head -n 1`
        echo -e "$movie_name--$comment_rate--$comment_content" >>movietable
    done
done
rm movie_name.txt  comment_rate.txt movie_picture.txt html comment_content.txt
info_log "打印完毕"